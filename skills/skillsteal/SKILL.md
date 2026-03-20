---
name: skillsteal
description: Steal skills from public GitHub repos into the local skills directory. Use when the user wants to add, import, or steal a skill from GitHub, or update previously stolen skills.
allowed-tools: Bash(gh api:*)
---

# Skillsteal

You help the user steal (copy) skills from public GitHub repositories into their local skills directory at the root of this repo under `skills/`.

## Stealing a skill

The user will provide either:

1. **A repo URL** like `https://github.com/mattpocock/skills/tree/main` — browse the repo, list available skills (subdirectories), and ask the user to pick **exactly one**. Never take more than one skill at a time unless the user explicitly asks for multiple.
2. **A direct skill URL** like `https://github.com/mattpocock/skills/tree/main/grill-me` — steal that specific skill directly.

### Steps

1. Parse the GitHub URL to extract owner, repo, branch, and path.
2. If the URL points to the repo root or a directory containing multiple skills, use `gh api` to list the subdirectories and present them to the user. Ask them to pick **one**.
3. Use `gh api` to fetch the full directory tree of the selected skill.
4. Recreate the skill directory locally under `skills/<skill-name>/`.
5. Download every file in the skill using `gh api` (raw content) and write them to the local directory, preserving the directory structure exactly.
6. **Add metadata** to the top of `SKILL.md` (the main entrypoint). Insert an HTML comment block at the very top of the file, **before** any existing content (including frontmatter):

```
<!-- skillsteal
source: <full GitHub URL to the skill directory>
commit: <latest commit hash of the source repo at time of steal>
stolen: <YYYY-MM-DD>
-->
```

To get the commit hash, run: `gh api repos/{owner}/{repo}/commits/{branch} --jq '.sha'`

7. Do NOT modify any other content in the skill files — keep them exactly as they are in the source repo.

## Updating stolen skills (`skillsteal update`)

When the user says "skillsteal update" or asks to update stolen skills:

1. Scan all directories under `skills/` for `SKILL.md` files containing the `<!-- skillsteal` metadata comment.
2. For each stolen skill found, display:
   - Skill name
   - Source URL
   - Date it was last stolen
   - Current commit hash vs latest commit hash from the source repo
3. **Ask the user which skills they want to update.** Never update automatically. Present the list and let them choose.
4. For each skill the user approves:
   - Re-fetch all files from the source, overwriting the local copies
   - Update the metadata comment with the new commit hash and today's date
   - Show a summary of what changed

## Important rules

- **One skill at a time** unless the user explicitly asks for more.
- **Never modify** the content of stolen skill files (except for the metadata comment in SKILL.md).
- **Always preserve** the exact directory structure from the source.
- **Always prompt** before updating — never auto-update.
- The skills directory is: `skills/` at the repo root (same level as `flake.nix`).
