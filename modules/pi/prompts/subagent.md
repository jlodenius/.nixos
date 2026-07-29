---
description: Delegate a task to a sub-agent
argument-hint: "<task>"
---
Spawn yourself as a sub-agent via bash to do the following task:

$@

Use `pi --print` with appropriate arguments. If the user specifies a model,
use `--provider` and `--model` accordingly.

Wait for the sub-agent to finish, then report its findings.
