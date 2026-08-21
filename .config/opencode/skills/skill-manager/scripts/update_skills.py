#!/usr/bin/env python3
"""
Skill manager for OpenCode.
Reads skills.jsonc, compares against skills.lock.json,
and installs/updates skills from GitHub repos.
"""

import json
import os
import shutil
import sys
import stat
import tarfile
from datetime import datetime, timezone
from fnmatch import fnmatchcase
from io import BytesIO
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

def get_config_dir() -> Path:
    """~/.config/opencode on all platforms (including Windows)."""
    return Path.home() / ".config" / "opencode"

CONFIG_DIR = get_config_dir()
SKILLS_DIR = CONFIG_DIR / "skills"
SKILLS_JSONC = CONFIG_DIR / "skills.jsonc"
LOCK_FILE = CONFIG_DIR / "skills.lock.json"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def strip_jsonc_comments(text: str) -> str:
    """Remove // and /* */ comments from JSONC (not inside strings)."""
    result = []
    i = 0
    in_string = False
    while i < len(text):
        ch = text[i]
        # Handle string boundaries (with proper escaped-quote handling)
        if ch == '"' and not in_string:
            in_string = True
            result.append(ch)
            i += 1
        elif ch == '"' and in_string:
            # Count preceding backslashes to handle \\\" correctly
            num_backslashes = 0
            j = i - 1
            while j >= 0 and text[j] == '\\':
                num_backslashes += 1
                j -= 1
            if num_backslashes % 2 == 0:
                in_string = False
            result.append(ch)
            i += 1
        elif not in_string and ch == '/' and i + 1 < len(text) and text[i + 1] == '/':
            # Line comment: skip to end of line
            while i < len(text) and text[i] != '\n':
                i += 1
        elif not in_string and ch == '/' and i + 1 < len(text) and text[i + 1] == '*':
            # Block comment: skip to closing */
            i += 2
            while i + 1 < len(text) and not (text[i] == '*' and text[i + 1] == '/'):
                i += 1
            i += 2  # skip past */
        else:
            result.append(ch)
            i += 1
    return ''.join(result)


def strip_trailing_commas(text: str) -> str:
    """Remove trailing commas before } or ] (not inside strings)."""
    import re
    return re.sub(r',\s*([}\]])', r'\1', text)


def read_jsonc(path: Path) -> dict:
    """Read a .jsonc file, strip comments and trailing commas, parse JSON."""
    text = path.read_text(encoding="utf-8")
    text = strip_jsonc_comments(text)
    text = strip_trailing_commas(text)
    return json.loads(text)


def read_lock() -> dict:
    """Read the lock file, or return empty structure."""
    if LOCK_FILE.exists():
        return json.loads(LOCK_FILE.read_text(encoding="utf-8"))
    return {"skills": {}}


def write_lock(lock: dict) -> None:
    """Write the lock file."""
    LOCK_FILE.write_text(
        json.dumps(lock, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


class RateLimitError(Exception):
    """Raised when the GitHub API returns 403 (rate limit exceeded)."""


def _ask_rate_limit_choice() -> str:
    """Ask the user how to proceed once, applies to all remaining skills."""
    answer = input(
        "  [s] Skip update checks  [f] Force update all  > "
    ).strip().lower()
    return "force" if answer.startswith("f") else "skip"


def github_api(url: str) -> dict:
    """GET a GitHub API URL, return parsed JSON."""
    req = Request(url, headers={"Accept": "application/vnd.github.v3+json"})
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        req.add_header("Authorization", f"token {token}")
    try:
        with urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as e:
        if e.code == 403:
            raise RateLimitError(
                "GitHub API rate limit exceeded (60 req/hr unauthenticated). "
                "Set GITHUB_TOKEN or GH_TOKEN env var to raise the limit."
            ) from e
        raise


# Cache: (source, ref) -> {path: sha} mapping from recursive tree
_tree_cache: dict[tuple[str, str], dict[str, str]] = {}
_skill_path_cache: dict[tuple[str, str], set[str]] = {}


def _resolve_commit_sha(source: str, ref: str) -> str:
    """Resolve a ref (branch, tag, or commit SHA) to a commit SHA."""
    # Try as a branch first
    try:
        ref_data = github_api(
            f"https://api.github.com/repos/{source}/git/ref/heads/{ref}"
        )
        obj = ref_data["object"]
        if obj["type"] == "commit":
            return obj["sha"]
        # Shouldn't happen for branches, but handle anyway
        commit_data = github_api(
            f"https://api.github.com/repos/{source}/git/commits/{obj['sha']}"
        )
        return commit_data["sha"]
    except HTTPError:
        pass

    # Try as a tag
    try:
        ref_data = github_api(
            f"https://api.github.com/repos/{source}/git/ref/tags/{ref}"
        )
        obj = ref_data["object"]
        if obj["type"] == "commit":
            return obj["sha"]
        # Annotated tag: object points to a tag object, dereference it
        if obj["type"] == "tag":
            tag_data = github_api(
                f"https://api.github.com/repos/{source}/git/tags/{obj['sha']}"
            )
            return tag_data["object"]["sha"]
    except HTTPError:
        pass

    # Try as a raw commit SHA
    try:
        commit_data = github_api(
            f"https://api.github.com/repos/{source}/git/commits/{ref}"
        )
        return commit_data["sha"]
    except HTTPError:
        pass

    raise ValueError(f"Could not resolve ref '{ref}' in {source} as branch, tag, or commit SHA")


def _fetch_full_tree(source: str, ref: str) -> dict[str, str]:
    """Fetch the full recursive tree for a repo+ref. Returns {path: sha} for trees."""
    cache_key = (source, ref)
    if cache_key in _tree_cache:
        return _tree_cache[cache_key]

    commit_sha = _resolve_commit_sha(source, ref)

    # Get root tree SHA from commit
    commit_data = github_api(
        f"https://api.github.com/repos/{source}/git/commits/{commit_sha}"
    )
    root_sha = commit_data["tree"]["sha"]

    # Fetch recursive tree (single API call, returns all paths)
    tree_data = github_api(
        f"https://api.github.com/repos/{source}/git/trees/{root_sha}?recursive=1"
    )

    path_to_sha = {}
    skill_paths = set()
    for item in tree_data.get("tree", []):
        if item["type"] == "tree":
            path_to_sha[item["path"]] = item["sha"]
        elif item["type"] == "blob" and item["path"].endswith("/SKILL.md"):
            skill_paths.add(item["path"].rsplit("/", 1)[0])

    _tree_cache[cache_key] = path_to_sha
    _skill_path_cache[cache_key] = skill_paths
    return path_to_sha


def get_tree_sha(source: str, path: str, ref: str) -> str:
    """Get the SHA of a directory tree in a GitHub repo.
    Uses a cached recursive tree fetch — one API roundtrip per repo+ref."""
    tree_map = _fetch_full_tree(source, ref)
    clean_path = path.rstrip("/")
    sha = tree_map.get(clean_path)
    if sha is None:
        raise ValueError(f"Path '{path}' not found in {source}@{ref}")
    return sha


# Cache: (source, ref) -> tarball bytes
_tarball_cache: dict[tuple[str, str], bytes] = {}


def _fetch_tarball(source: str, ref: str, use_codeload: bool = False) -> bytes:
    """Fetch and cache the tarball for a repo+ref.
    codeload.github.com is not subject to the api.github.com rate limit."""
    cache_key = (source, ref)
    if cache_key in _tarball_cache:
        return _tarball_cache[cache_key]

    if use_codeload:
        tarball_url = f"https://codeload.github.com/{source}/tar.gz/{ref}"
        req = Request(tarball_url)
    else:
        tarball_url = f"https://api.github.com/repos/{source}/tarball/{ref}"
        req = Request(tarball_url, headers={"Accept": "application/vnd.github.v3+json"})
        token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
        if token:
            req.add_header("Authorization", f"token {token}")

    with urlopen(req, timeout=120) as resp:
        data = resp.read()

    _tarball_cache[cache_key] = data
    return data


def _matches_path_pattern(path: str, pattern: str) -> bool:
    """Match glob wildcards within path segments (so * never crosses /)."""
    path_parts = path.rstrip("/").split("/")
    pattern_parts = pattern.rstrip("/").split("/")
    return len(path_parts) == len(pattern_parts) and all(
        fnmatchcase(part, pattern_part)
        for part, pattern_part in zip(path_parts, pattern_parts)
    )


def get_matching_skill_paths(
    source: str, pattern: str, ref: str, use_codeload: bool = False
) -> list[str]:
    """Return skill directories matching a glob path."""
    cache_key = (source, ref)
    if use_codeload:
        tarball_bytes = _fetch_tarball(source, ref, use_codeload=True)
        with tarfile.open(fileobj=BytesIO(tarball_bytes), mode="r:gz") as tar:
            members = tar.getmembers()
            if not members:
                raise ValueError(f"Empty tarball from {source}@{ref}")
            prefix = members[0].name.split("/")[0] + "/"
            skill_paths = {
                member.name[len(prefix):].rsplit("/", 1)[0]
                for member in members
                if member.isfile()
                and member.name.startswith(prefix)
                and member.name.endswith("/SKILL.md")
            }
    else:
        _fetch_full_tree(source, ref)
        skill_paths = _skill_path_cache[cache_key]

    matches = sorted(
        path for path in skill_paths if _matches_path_pattern(path, pattern)
    )
    if not matches:
        raise ValueError(f"Pattern '{pattern}' matched no skills in {source}@{ref}")
    return matches


def _rm_readonly(func, path, exc_info):
    """Error handler for shutil.rmtree to handle read-only files on Windows."""
    os.chmod(path, stat.S_IWRITE)
    func(path)


def backup_modified_files(dest: Path, installed_at: str) -> list[tuple[Path, bytes]]:
    """Find files modified after installed_at and return their relative paths + contents."""
    threshold = datetime.fromisoformat(installed_at)
    backups = []
    for f in dest.rglob("*"):
        if not f.is_file() or f.suffix == ".bak":
            continue
        mtime = datetime.fromtimestamp(f.stat().st_mtime).astimezone()
        if mtime > threshold:
            backups.append((f.relative_to(dest), f.read_bytes()))
    return backups


def restore_backups(dest: Path, backups: list[tuple[Path, bytes]]) -> None:
    """Write .bak files alongside new files, skip if content is identical."""
    for rel, content in backups:
        new_file = dest / rel
        if new_file.exists() and new_file.read_bytes() == content:
            print(f"  Skipped backup: {rel} (content unchanged)")
            continue
        bak = dest / (str(rel) + ".bak")
        bak.parent.mkdir(parents=True, exist_ok=True)
        bak.write_bytes(content)
        print(f"  Backed up: {rel} -> {rel}.bak")


def download_and_extract(source: str, path: str, ref: str, dest: Path, use_codeload: bool = False) -> None:
    """Download a subdirectory from a GitHub repo and extract to dest."""
    tarball_bytes = _fetch_tarball(source, ref, use_codeload=use_codeload)

    # The tarball contains a top-level dir like "owner-repo-sha/"
    # We need to find entries under "owner-repo-sha/{path}/"
    path_suffix = path.rstrip("/") + "/"

    with tarfile.open(fileobj=BytesIO(tarball_bytes), mode="r:gz") as tar:
        # Find the top-level prefix
        members = tar.getmembers()
        if not members:
            raise ValueError(f"Empty tarball from {source}@{ref}")
        prefix = members[0].name.split("/")[0] + "/"

        # The full prefix for our target path
        target_prefix = prefix + path_suffix

        # Clean destination
        if dest.exists():
            shutil.rmtree(dest, onerror=_rm_readonly)
        dest.mkdir(parents=True, exist_ok=True)

        # Extract matching members
        extracted = 0
        for member in members:
            if member.name.startswith(target_prefix) and member.name != target_prefix.rstrip("/"):
                # Rewrite the path to be relative to dest
                rel = member.name[len(target_prefix):]
                if not rel:
                    continue
                member_copy = tarfile.TarInfo(name=rel)
                member_copy.size = member.size
                member_copy.mode = member.mode
                member_copy.type = member.type

                if member.isdir():
                    (dest / rel).mkdir(parents=True, exist_ok=True)
                elif member.isfile():
                    (dest / rel).parent.mkdir(parents=True, exist_ok=True)
                    f = tar.extractfile(member)
                    if f is not None:
                        (dest / rel).write_bytes(f.read())
                        f.close()
                    os.chmod(dest / rel, member.mode or 0o644)
                extracted += 1

        if extracted == 0:
            raise ValueError(
                f"No files found for path '{path}' in {source}@{ref}"
            )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def sync_skills() -> None:
    """Main entry point: sync skills from skills.jsonc."""
    if not SKILLS_JSONC.exists():
        print(f"{SKILLS_JSONC} not found. Creating a template...")
        template = """\
{
  // Add skills to install from GitHub repos.
  // Each entry needs "source" (owner/repo) and "path" (directory or glob in repo).
  // Optional "ref" to pin a branch, tag, or commit SHA (defaults to "main").
  //
  // Example:
  //   { "source": "anthropics/skills", "path": "skills/docx" }
  //   { "source": "anthropics/skills", "path": "skills/*" }
  //   { "source": "anthropics/skills", "path": "skills/pdf", "ref": "v1.0.0" }
  "skills": []
}
"""
        SKILLS_JSONC.parent.mkdir(parents=True, exist_ok=True)
        SKILLS_JSONC.write_text(template, encoding="utf-8")
        print(f"Created {SKILLS_JSONC}")
        print("Add skill entries to the \"skills\" array and run this script again.")
        return

    config = read_jsonc(SKILLS_JSONC)
    skills = config.get("skills", [])
    if not skills:
        print("No skills defined in skills.jsonc.")
        return

    lock = read_lock()
    lock_skills = lock.get("skills", {})

    added = []
    updated = []
    skipped = []
    errors = []
    rate_limited_choice = None  # None=not hit yet, "skip", or "force"

    skills = list(skills)
    while skills:
        entry = skills.pop(0)
        source = entry["source"]
        path = entry["path"]
        ref = entry.get("ref", "main")
        name = path.rstrip("/").split("/")[-1]

        print(f"\n--- {name} ({source}/{path}@{ref}) ---")

        if rate_limited_choice == "skip":
            print("  Skipped (rate limited).")
            skipped.append(name)
            continue

        if any(char in path for char in "*?["):
            try:
                matches = get_matching_skill_paths(
                    source, path, ref, use_codeload=(rate_limited_choice == "force")
                )
            except RateLimitError as e:
                print(f"  {e}")
                rate_limited_choice = _ask_rate_limit_choice()
                if rate_limited_choice == "skip":
                    skipped.append(name)
                    continue
                try:
                    matches = get_matching_skill_paths(
                        source, path, ref, use_codeload=True
                    )
                except Exception as e:
                    print(f"  ERROR expanding wildcard: {e}")
                    errors.append(name)
                    continue
            except Exception as e:
                print(f"  ERROR expanding wildcard: {e}")
                errors.append(name)
                continue

            print(f"  Matched {len(matches)} skills.")
            skills[0:0] = [{**entry, "path": match} for match in matches]
            continue

        remote_sha = None
        if rate_limited_choice != "force":
            try:
                remote_sha = get_tree_sha(source, path, ref)
            except RateLimitError as e:
                print(f"  {e}")
                rate_limited_choice = _ask_rate_limit_choice()
                if rate_limited_choice == "skip":
                    skipped.append(name)
                    continue
            except Exception as e:
                print(f"  ERROR fetching remote SHA: {e}")
                errors.append(name)
                continue

        local_info = lock_skills.get(name)
        local_sha = local_info["installed_sha"] if local_info else None
        dest = SKILLS_DIR / name
        dir_exists = dest.exists() and (dest / "SKILL.md").exists()

        if remote_sha is not None and local_sha == remote_sha and dir_exists:
            print(f"  Up to date (SHA: {remote_sha[:12]})")
            skipped.append(name)
            continue

        if remote_sha is not None and local_sha == remote_sha and not dir_exists:
            print(f"  Re-installing (SHA matches but directory missing)...")
        if remote_sha is None:
            print("  Force-installing via codeload (no version check)...")
        else:
            action = "Updating" if local_sha else "Installing"
            print(f"  {action}... (local: {(local_sha or 'none')[:12]}, remote: {remote_sha[:12]})")

        try:
            backups = []
            if local_info and dir_exists:
                backups = backup_modified_files(dest, local_info["installed_at"])
            download_and_extract(source, path, ref, dest, use_codeload=(remote_sha is None))
            if backups:
                restore_backups(dest, backups)
        except Exception as e:
            print(f"  ERROR downloading: {e}")
            errors.append(name)
            continue

        lock_skills[name] = {
            "source": source,
            "path": path,
            "ref": ref,
            "installed_sha": remote_sha,
            "installed_at": datetime.now().astimezone().isoformat(),
        }

        if local_sha:
            updated.append(name)
        else:
            added.append(name)
        print(f"  Done.")

    # Save lock file
    lock["skills"] = lock_skills
    write_lock(lock)

    # Summary
    print("\n========== Summary ==========")
    if added:
        print(f"  Added:   {', '.join(added)}")
    if updated:
        print(f"  Updated: {', '.join(updated)}")
    if skipped:
        print(f"  Skipped: {', '.join(skipped)} (up to date)")
    if errors:
        print(f"  Errors:  {', '.join(errors)}")
    if not added and not updated and not errors:
        print("  Everything is up to date.")


if __name__ == "__main__":
    sync_skills()
