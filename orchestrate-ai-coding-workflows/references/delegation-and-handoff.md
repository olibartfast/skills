# Delegation and Handoff

Adapted from [AI Coding Workflows: From Cloud to Local](https://olibartfast.ninja/blog/ai-coding-workflows-cloud-to-local.html).
The contract artifacts these packets presuppose, the scoreboard declaration, and
attempt-log/run-ledger terminology are owned by
[workflow-contract.md](workflow-contract.md). Command and write enforcement is
owned by [permissions-and-local-inference.md](permissions-and-local-inference.md).

## Contents

- Role selection by task
- Model routing by capability
- The same-model delegation trap
- Orchestrator context relocation
- Handoff packet template
- Planner-redelegates-defects
- Repeated controlled comparisons
- Advisory vs harness-enforced boundaries

## Role selection by task

Choose the configuration from the nature of the work, not from a leaderboard:

| Task | Reasonable configuration |
|---|---|
| Novel architecture, unclear requirements, subtle concurrency/lifetime bug | Single capable model, one context — judgement is the bottleneck; delegation only adds overhead |
| Well-specified phases in an established codebase | Capable planner, cheap implementers — the default for routine work |
| Cost pressure or vendor-independence requirement | Open-weight workers behind a router, planner unchanged |
| Confidential code, offline work, unmetered experimentation | Local worker, capable planner; phases sized accordingly |
| Mechanical work with strong test coverage | Fully local, review the only cloud step — or none |

Mixing is the mature answer: the constraints, roadmap, and acceptance suite are durable assets; the model configuration is a per-task dial.

## Model routing by capability

Route by role and capability tier, not by model name; names age, roles survive
replacement. Assign models in configuration (per-role agent definitions), not
in prompts.

| Role | Capability profile | Typical assignments |
|---|---|---|
| Architect / reviewer | Ambiguous, expensive to get wrong: concurrency design, ABI questions, review that can reject a diff | Strongest available tier |
| Planner / orchestrator | Decomposing a phase, writing the handoff packet, normal feature work | Mid tier |
| Implementer | Clear, repeatable, objective checks — bounded scope with a pass/fail scoreboard | Cheap or local tier |

"Clear, repeatable, with objective checks" is manufactured by the specification
work, not a property the task arrives with: a bounded target with named sources
and a pass/fail scoreboard qualifies, "make this module thread-safe" does not.
The price spread between tiers is the return on tightening the brief.

Capability checklist before committing to a tier: does the task require
judgement (invariants, ABI, design) or transcription; is the worker's context
window, tool-calling reliability, and instruction adherence adequate for the
packet as written. File-level routing config: [configuration-and-measurement.md](configuration-and-measurement.md).

## The same-model delegation trap

Splitting work across subagents on the same model made early runs *more*
expensive, not less: ~50% more context and turns, ~20% more tool calls, higher
cost than the single-context baseline. Every handoff re-reads the same headers,
rediscovers the same conventions, and returns a summary the orchestrator pays
to absorb — at premium rates.

Rules:

- Delegation is an investment that pays only when the worker role changes model
  (or location); judge the split at that step. Treat the first split's overhead
  as the price of building an explicit delegation interface — keep it anyway if
  that interface is the goal.
- Same-model delegation is justified mainly for isolation (fresh context,
  reviewability), never for token savings.

## Orchestrator context relocation

When work moves to many small workers, average worker context drops sharply,
and the orchestrator's context grows by nearly as much as the workers saved —
total context barely moves, and whoever composes briefs and reviews
results is the expensive model.

Consequences (planner/worker separation is elaborated in
[configuration-and-measurement.md](configuration-and-measurement.md)):

- Measure planner and worker separately as
  [workflow-contract.md](workflow-contract.md) requires, or the relocation is invisible.
- Prefer fewer, better-briefed workers over maximal decomposition; keep brief
  composition cheap — point at contract artifacts, never paste their contents.

## Handoff packet template

The packet is the interface between the two roles; size it for the worker's
actual capacity, not yours.

```markdown
## Delegation packet — <phase name>

Writable paths (nothing beyond these):
  - <repo/path — new | modify: what change is expected>
  - ...

Read-only — read these, never modify them:
  - <repo/path — the interface to implement against>
  - <acceptance suite location — the scoreboard that judges you>

Permitted development commands (build, targeted tests, scoreboard), which the
worker may run and assume; actual command enforcement lives in the per-phase
permission configuration (see permissions-and-local-inference.md).

Required final state (what must be true when done):
  - <public surface, behaviour, error handling, exact identifiers
     and strings where tests assert on them>
  - <existing behaviour that must survive unchanged>
  - <constraints inherited from the contract: no new dependencies,
     no ABI changes, ...>

Working method:
  - For every writable file, write the complete final content; never patch by anchor.
  - Read the real file before changing it; build and run targeted checks as often as useful.

Scoreboard, run once as your final action:
  <single scoreboard command from the workflow contract>
  Stop after it, pass or fail, and report.
```

What the packet includes at minimum: writable paths and nothing beyond them;
read-only paths; permitted development commands; complete required final state
in prose; exact identifiers where they are contract requirements; a named
scoreboard command; an explicit stop condition.

What to leave out:

- Pointers into the specification directory — following references costs the
  worker context it does not have.
- A paste of whole files.
- Finished code — otherwise you have paid the expensive model to produce it and
  the cheap one to copy it.

Every clause in the required-final-state block is something the acceptance suite
can check and a reviewer can reject on: the packet fixes the obligations; the
worker chooses the implementation. It is model-independent (the same brief
works on a frontier, hosted open-weight, or local worker) and inspectable
mid-run — reading it tells you whether delegation matches intent before the diff does.

## Planner-redelegates-defects

Failure mode to watch for: the planner, seeing weak output, quietly rewrites the
code itself. Cost returns to the single-model baseline while the workflow still
looks delegated.

- Instruct the planner to send defects back to a fresh worker (fresh context,
  updated packet) rather than rewriting them itself; a fresh worker with a
  corrected packet is usually cheaper than a long context edited in place.
- Verify by checking which role consumed the tokens — the run ledger shows it.

## Repeated controlled comparisons

A single run proves little; these systems are stochastic. Comparisons are
controlled: one variable per comparison, same task, constraints, starting
revision, and packet structure; fresh context per run with revert between runs;
each configuration run more than once. If changing model required changing the
workflow, record it — that row compares a different way of working, not just
different weights. Record runs in the attempt log. The full comparison
checklist, including reasoning-effort pinning, is owned by
[configuration-and-measurement.md](configuration-and-measurement.md).

## Advisory vs harness-enforced boundaries

Prompt and agent-definition body text is persuasion; configuration is enforced —
a worker told not to write code may obey in one phase and ignore it in the next.
Write the enforced part as an allowlist: a rule that permits everything except
the specs still lets the worker edit the manifest, presets, acceptance suite,
and its own definition. Which lever is enforced where is a permissions question
(see [permissions-and-local-inference.md](permissions-and-local-inference.md));
the delegation-owned part of that boundary:

- Where a harness offers fine-grained per-path write rules, regenerate the
  permission block per phase so it agrees with the packet — this forces the
  scope decision before the worker starts, not in the diff.
- Where it offers only coarse boundaries (may write anywhere in the working
  tree), "these files and no others" becomes a review obligation — name it as
  such instead of pretending the instruction enforces it.
- Reviewer roles should be read-only by configuration (deny write/edit tools,
  read-only sandbox, or deny-by-default permission block) rather than by
  instruction; read-only review is what makes a report trustworthy about work
  produced by a model you would not trust unsupervised.
- Step/turn ceilings are advisory levers from the delegation side and
  harness-enforced only where that file says so. In Claude Code, `maxTurns` is
  per-invocation: a child that reaches it returns partial output and the parent
  still owns termination across invocations; Codex has no documented per-agent
  cap. Either way, termination must come from the parent workflow: one phase per
  delegation, one scoreboard run required, and check that the child returned
  rather than trusting it to stop.
