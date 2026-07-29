---
description: Delegate a task to a sub-agent
argument-hint: "<task>"
---
Spawn yourself as a sub-agent via bash to do the following task:

$@

Use `pi --print` with appropriate arguments and run it from the current working directory so the sub-agent has access to the same project. If the user specifies a model, use `--provider` and `--model` accordingly.

Do not perform the task yourself. Wait for the sub-agent to finish, then report its result, including any changes it made and tests it ran.
