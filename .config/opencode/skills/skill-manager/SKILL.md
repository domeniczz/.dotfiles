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

The script uses the GitHub API. If you hit rate limits, set a `GITHUB_TOKEN` or `GH_TOKEN` environment variable with a personal access token.
