---
name: commit
description: Commits current repository changes in coherent, independently understandable chunks. Use when the user asks to commit changes, create commits, or invokes /commit.
---

# Commit Changes

## Workflow

1. Read the repository instructions and run `git status --short --branch`.
2. Inspect all relevant staged and unstaged diffs, including untracked files. Never assume staged changes form the right commit.
3. Separate changes by purpose. Each commit should represent one independently understandable change that can be reviewed or reverted on its own.
4. Identify unrelated, generated, secret, or suspicious files and leave them uncommitted. Never discard or overwrite them.
5. Run the narrowest relevant checks before committing. If checks cannot run or fail, report that clearly; do not conceal failures.
6. Stage only the files or hunks belonging to the next chunk. Prefer explicit paths and non-interactive commands.
7. Review `git diff --cached --check`, `git diff --cached --stat`, and the complete staged diff.
8. Commit with a concise imperative subject. Add a body only when it explains non-obvious motivation or constraints.
9. Repeat for each coherent chunk, then show the resulting commits and remaining working-tree state.

## Commit Rules

- Preserve the user's existing changes and staging intent while regrouping only when needed for coherent commits.
- Do not mix formatting, refactoring, fixes, generated files, or unrelated features without a concrete reason.
- Do not create empty commits or bypass hooks unless the user explicitly requests it.
- Do not amend, rebase, force-push, or otherwise rewrite history unless explicitly requested.
- Never add AI attribution, `Co-authored-by` trailers for an AI agent, or claims about authorship.
- Do not push commits unless explicitly requested.

If the changes cannot be separated safely, explain why and ask the user how to proceed.
