---
name: project-agent
description: Manually launch a Pi agent for a project under ~/Development.
disable-model-invocation: true
---

Interpret the arguments as a natural-language task and project reference; ask if either is unclear.

1. Resolve the referenced project strictly inside `~/Development`: use an existing relative path, otherwise search recursively for an exact directory name. Exclude `.git`, `node_modules`, and `.direnv`; ask if missing or ambiguous. Use its Git root when available.
2. Use the Paj extension's `get_agent_name` tool to get this session's exact report recipient.
3. Create a unique, detached tmux session rooted at the project and launch `pi --name <session> <prompt>`. Pass the task without shell interpolation. The prompt must tell the agent to do the task, follow project instructions, and report its result to this session with `send_agent_message` when finished.
4. Report the tmux session name and resolved project root.
