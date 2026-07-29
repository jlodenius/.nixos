---
name: project-agent
description: Manually launch a Pi agent for a project under ~/Development.
disable-model-invocation: true
---

Arguments: `<project path-or-name> -- <task>`.

1. Resolve the project strictly inside `~/Development`: use an existing relative path, otherwise search recursively for an exact directory name. Exclude `.git`, `node_modules`, and `.direnv`; ask if missing or ambiguous. Use its Git root when available.
2. Identify this Pi session with `paj --json session list` by matching its PID to `$PPID`; retain its exact name for the report.
3. Create a unique, detached tmux session rooted at the project and launch `pi --name <session> <prompt>`. Pass the task without shell interpolation. The prompt must tell the agent to do the task, follow project instructions, and report its result to this session with `send_agent_message` when finished.
4. Report the tmux session name and resolved project root.
