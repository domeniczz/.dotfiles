---
name: skill-manager
description: Manage OpenCode skills from GitHub repositories. Use this skill whenever the user wants to install, update, or check the status of their skills, or ask about managing skills.
---

# Skill Manager

Manages skills defined in `~/.config/opencode/skills.jsonc`. Installs new skills and updates existing ones from GitHub repos.

## How it works

- `skills.jsonc` — user-managed list of skills to install (source repo, path, optional ref)
- `skills.lock.json` — auto-managed lock file tracking installed commit SHAs
- `scripts/update_skills.py` — the sync engine that compares local vs remote and installs/updates

## Usage

Run the update script:

```bash
python ~/.config/opencode/skills/skill-manager/scripts/update_skills.py
```

If `python` is not found, try the following in order:

1. `python3 ~/.config/opencode/skills/skill-manager/scripts/update_skills.py`
2. `conda run -n base python ~/.config/opencode/skills/skill-manager/scripts/update_skills.py`
3. If no Python environment is available, abort and inform the user that Python is required.

## What the script does

1. Reads `skills.jsonc` to get the list of desired skills
2. Reads `skills.lock.json` to see what's currently installed
3. For each skill, checks the GitHub API for the current tree SHA
4. If the skill is missing locally → installs it
5. If the SHA differs → updates it
6. If the SHA matches → skips it
7. Writes updated `skills.lock.json`

## Adding a new skill

Edit `~/.config/opencode/skills.jsonc` and add an entry:

```jsonc
{ "source": "anthropics/skills", "path": "skills/frontend-design" }
```

Then run `/update-skills`.

## Pinning a version

Add a `ref` field to pin to a specific branch, tag, or commit:

```jsonc
{ "source": "anthropics/skills", "path": "skills/docx", "ref": "v1.0.0" }
```

## GitHub rate limits

The script uses `api.github.com` to check for updates (60 req/hr unauthenticated — easy to exhaust, unrelated to any git push/pull SSH credentials you already have). On a 403 (rate limit), it prompts once: "Skip update checks" or "Force update all". Force falls back to `codeload.github.com` (unauthenticated, not rate-limited) and always re-downloads without a version check.

To avoid hitting the limit at all, set a `GITHUB_TOKEN` or `GH_TOKEN` env var with a personal access token (no special scopes needed, public repo read access is enough).
