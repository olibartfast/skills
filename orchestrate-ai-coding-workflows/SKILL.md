---
name: orchestrate-ai-coding-workflows
description: "Design and execute model-replaceable AI coding workflows for coding agents and subagents across cloud, routed open-weight, and local inference (Ollama, LM Studio, or other local LLM runtimes), including OpenCode, Claude Code, and Codex agent definitions. Use when defining engineering contracts, planner/implementer roles, delegation packets, permission boundaries, acceptance validation, model routing, or measurements of coding-agent quality, context, cost, and intervention. Use design-ai-systems instead for production AI/ML system architecture."
---

# Orchestrate AI Coding Workflows

Treat the coding agent as an arrangement of replaceable parts: a harness, an inference
provider, a planning role, an implementation role, and an execution location. Build the
workflow so the model behind each role can change without changing the engineering contract.
For production AI/ML system architecture (data, serving, deployment), use the
`design-ai-systems` skill instead; this skill covers orchestration of coding agents
against a repository. Background on measured tradeoffs (delegation economics, context
relocation, local inference): see
[AI Coding Workflows: From Cloud to Local](https://olibartfast.ninja/blog/ai-coding-workflows-cloud-to-local.html)
and the DeepLearning.AI short course it summarizes.

**Routing:** use `apply-spec-driven-development` first when the intent is to discover
requirements and drive a feature from living specs — it owns discovery and maintenance of
`mission.md`, `tech-stack.md`, `roadmap.md`, `requirements.md`, `plan.md`, and
`validation.md`. This skill takes over when an approved phase needs delegation, model
routing, permission boundaries, handoff packets, or measurement across replaceable models.

## Choose the task

- **Design a workflow:** Establish the contract, roles, and boundaries for a repository.
- **Delegate a phase:** Prepare a handoff packet and enforce worker boundaries.
- **Review or compare configurations:** Interpret measurements and pick per-task routing.

## Follow the workflow

### 1. Inspect the repository and harness first

Inventory build/test entry points, existing agent definitions, permission mechanisms, and
routing options, plus the harness capability model (per-path write rules, tool allowlists,
step ceilings, enforced vs advisory). Never assume the default harness configuration is
safe: coarse "workspace-write" settings allow editing the acceptance suite, manifests, and
presets unless something explicitly denies it.

### 2. Establish the engineering contract

Introduce four version-controlled artifacts — intent, constraints, phased roadmap, and
acceptance — that make model swapping a configuration change instead of a rewrite.
Acceptance is one command that settles whether a phase is done, owned by the phase's
specifier, never writable by what it scores; worker tests are output, not acceptance.
Templates and details: [workflow-contract.md](references/workflow-contract.md).

### 3. Assign roles and models by task, not habit

Route by capability tier and role name, not by model name: strongest tier for judgement
(architecture, ambiguous requirements, review that rejects diffs); mid tier for orchestration;
cheap or local tier for well-specified mechanical work. Two corrections against instinct:
delegation on one model costs more than it saves, and context pressure relocates to the
planner rather than vanishing. Routing tables:
[delegation-and-handoff.md](references/delegation-and-handoff.md).

### 4. Write handoff packets as the delegation interface

A packet must state: writable paths (nothing beyond them), read-only paths (interfaces plus
the acceptance suite), required final state as checkable obligations, exact identifiers where
they are contracts, permitted commands, the single acceptance command to run exactly once,
and a stop condition. Leave out spec directories, pasted files, and finished code; size it
for the worker's context window. Permitted commands must match the per-phase permission
configuration ([permissions-and-local-inference.md](references/permissions-and-local-inference.md));
packet template: [delegation-and-handoff.md](references/delegation-and-handoff.md).

### 5. Enforce boundaries; treat prompts as advisory

What matters belongs where the harness enforces it, written as allowlists; prompt rules are
persuasion, especially for small models. Deny by default; workers get a step ceiling, whole-file
writes, one acceptance run and no repair; reviewers get broad read access and zero write access.
Mark each rule harness-enforced or advisory. Deny-by-default templates and harness mapping for
OpenCode, Claude Code, and Codex:
[permissions-and-local-inference.md](references/permissions-and-local-inference.md).

### 6. Start clean, never destroy dirty work

Start each controlled run from a known revision with fresh context. In-tree runs require
a clean tree; if it is dirty, prefer an isolated scratch worktree and let the planner or
a human resolve pre-existing dirty state. Never revert, stash, or discard user work
automatically. Cleanup may touch only paths the run itself created, must abort and report
on unexpected or concurrent changes, and must verify the return to the starting revision.
Do not carry a long prior context into a new task.

### 7. Iterate freely, score once

Let the worker compile and run targeted checks freely — the compiler is its fastest
feedback — but run the single acceptance command exactly once per attempt, as the final
action, reporting the result whether it passes or fails. A worker that edits and reruns
validation in a loop turns a cheap failure into an expensive spiral; the planner decides
what happens next. Scoring rules: [workflow-contract.md](references/workflow-contract.md).

### 8. Keep the planner from silent self-repair

When a worker returns defects, the planner quietly rewriting the code itself returns
cost to the single-model baseline while the work still looks delegated. Send defects
back in a fresh, corrected packet and verify that implementation tokens were consumed
by the worker role. Repair discipline:
[delegation-and-handoff.md](references/delegation-and-handoff.md).

### 9. Measure by role; compare under control

Record metrics per run, split planner versus worker — total and active context, tool calls,
turns, wall-clock, metered cost, outcome (first-pass validation result recorded in the attempt log), intervention count — into an
attempt log / run ledger, one entry per attempt. Run controlled comparisons: same task,
phases, prompt shape, one variable at a time, repeated more than once, reasoning effort
pinned on both sides. Metrics catalogue, turn-count caveat, run-ledger template, and
comparison procedure:
[configuration-and-measurement.md](references/configuration-and-measurement.md).

### 10. Local inference: close egress, size for the weakest participant

Serving locally adds privacy and removes marginal token cost, but audit every egress
path — web tools, package installs, MCP servers, telemetry — not just the model
endpoint, keeping the audit in committed configuration. Split phases until each packet
fits a small context window with simple whole-file tool calls, with a modest served
window on purpose. Read model identifiers from the runtime rather than hardcoding them.
Egress checklist:
[permissions-and-local-inference.md](references/permissions-and-local-inference.md).

### 11. Produce the deliverable

A workflow design includes: intent, constraints, phased roadmap, and immutable acceptance
command; role/model assignments in committed configuration; handoff packet templates with
permission blocks regenerated per phase; an explicit harness-enforced vs advisory boundary
model; a measurement plan with run-ledger template; known risks (planner self-repair,
context relocation, local-inference limits). Choose configuration per task, not per project:
capable judgement model where work is hard, capable planner plus cheap implementers for
routine phases, local workers for confidential or mechanical work, review the only cloud step.

## References

- [references/workflow-contract.md](references/workflow-contract.md) — intent, constraints, phased
  roadmap, immutable acceptance, scoring discipline.
- [references/delegation-and-handoff.md](references/delegation-and-handoff.md) — role assignment, packet
  design, planner/worker measurement, repair discipline.
- [references/permissions-and-local-inference.md](references/permissions-and-local-inference.md) — deny-by-default
  permissions, read-only review, clean starts, egress auditing.
- [references/configuration-and-measurement.md](references/configuration-and-measurement.md) — committed configuration,
  metrics catalogue, attempt log, controlled measurement.

The `design-ai-systems` skill takes over when the output is a deployed AI/ML system
rather than orchestrated coding work.
