---
name: choose-agent-workflow
description: Recommend how to coordinate an AI task using one agent, a code-driven workflow, parallel workers, verification, or hierarchical delegation. Use when choosing or reviewing a coordination approach and its trade-offs; this skill provides advice rather than executing the workflow.
---

# Choose Agent Workflow

Recommend the simplest setup that fits the user's task and constraints. Treat “best” as a
provisional fit, not a universal winner. This skill produces a recommendation: do not launch
agents, edit files, install tools, or run the proposed workflow merely to answer the request.
If the user separately requests implementation, treat that as a distinct execution task
under their existing authorization; the recommendation itself grants no permissions.

## Establish the decision criteria

Use the context already supplied to identify:

- The required result and how success can be checked.
- Whether steps are known and repeatable or require discovery and judgment.
- Dependencies between subtasks, shared data or files, and whether changes can be isolated.
- The actual bottleneck: quality, elapsed time, cost, context size, or coordination load.
- Available tools, concurrency, model and permission controls, and relevant privacy limits.

Ask only about missing information that could materially change the choice. Otherwise state
reasonable assumptions and give a provisional recommendation. Do not invent workloads,
runtime capabilities, cost savings, or performance percentages.

## Choose and combine patterns

| Situation | Starting recommendation | Main limitation |
| --- | --- | --- |
| Open-ended, tightly coupled reasoning or changes | One agent with tools and selective context loading | Context and serial execution can limit scale |
| Known, repeatable steps or batches | Code-driven workflow with model calls where judgment is needed | Up-front implementation and maintenance |
| Independent searches, reviews, or work packages | Flat fan-out with one integration owner | Duplicate work, aggregation cost, and coordination overhead |
| Predictable artifact transformations | Sequential pipeline with explicit handoffs | Errors can propagate and dependent stages remain serial |
| Quality is the bottleneck and acceptance criteria exist | Add a generator/verifier loop to the chosen setup | Review costs more and reviewers can share the generator's mistakes |
| Specialists repeatedly need evolving shared state | Add a structured shared workspace | Ownership, versioning, and conflict resolution become necessary |
| Subtasks themselves need substantial coordination | Bounded hierarchical delegation | Additional handoffs, latency, and information loss |

These patterns are composable. A code-driven workflow can fan out workers and then verify
their outputs; a shared workspace can support either a flat or hierarchical arrangement.
Recommend deeper delegation only where a concrete coordination need justifies it, with
limits on depth, concurrent work, and total effort. Workload size alone does not justify it.

For context pressure alone, consider selective retrieval, durable notes, and compaction
before adding agents. Explain that notes and compaction can also omit details.

Parallel reads with one integration owner are a useful starting point for engineering.
Parallel edits can be appropriate when ownership and interfaces are clear, changes are
isolated, and integration checks exist. A shared directory alone is not conflict management.
Do not assume separate agent contexts imply separate filesystems or enforced permissions.

## Make the recommendation concrete

Describe roles and information flow at the level needed for this task. For delegated work,
suggest a handoff containing the original goal and constraints, bounded scope, dependencies,
allowed actions, acceptance criteria, and expected output. Preserve exact source references
and important requirements instead of repeatedly paraphrasing them.

For large results, recommend durable artifacts plus a concise return message with their
locations, key findings, evidence, assumptions, unresolved issues, and validation status.
Artifacts make details retrievable; they do not guarantee that an integrator reads them.
Identify who resolves disagreements and integrates the final result.

For verification, prefer objective tests or independent evidence where available. A second
agent or a majority vote is not proof of correctness. Specify a review rubric and a bounded
revision or escalation condition when recommending a verifier loop.

When cost or speed determines the choice, suggest a representative comparison against a
simpler baseline using the same acceptance criteria. Include total cost, elapsed time,
quality, and human intervention; do not promise a speedup merely from more concurrency.

## Return a concise recommendation

Adapt detail to the task, normally covering:

1. **Recommended setup:** one clear choice, including useful combinations.
2. **Why it fits:** the task facts or stated assumptions that drive the choice.
3. **Responsibilities and checks:** who does what, how results move, and how success is verified.
4. **Main trade-off:** the likely cost or failure mode and a simpler alternative where one exists.
5. **When to change it:** an observable condition that would justify more or less coordination.

Use plain language and explain unfamiliar pattern names. Avoid producing a full framework,
prompt library, or implementation when the user only wants a recommendation.
