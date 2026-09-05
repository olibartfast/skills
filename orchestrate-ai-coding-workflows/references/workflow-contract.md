# Workflow Contract

Adapted from [AI Coding Workflows: From Cloud to Local](https://olibartfast.ninja/blog/ai-coding-workflows-cloud-to-local.html).

The durable part of an AI coding workflow is not the model. It is the contract the
model works under: written constraints, executable validation, and an explicit
boundary between planning and implementation. If those live in the repository,
swapping the model, provider, or worker role is a configuration change. If they
live in a chat transcript, every swap is a rewrite.

This file owns the contract artifacts and the acceptance-scoreboard declaration
(the command that decides the outcome). Record results in the attempt log — the
run ledger defined in
[configuration-and-measurement.md](configuration-and-measurement.md).

## Contents

- Contract artifacts
- Constraints checklist
- Phased roadmap
- Acceptance scoreboard declaration
- One score-adjudication run per attempt
- Targeted checks vs the full scoreboard
- Measuring by role
- Start clean without touching existing dirty state

## Contract artifacts

Four artifacts, under version control, given to every run unchanged:

| Artifact | Contains | Owned by |
|---|---|---|
| Intent | What the software does and who it serves | Specifier |
| Constraints | Decisions already made; not the agent's to revisit | Specifier |
| Roadmap | Work split into phases, implemented and judged one at a time | Planner |
| Acceptance tests | The judgement for each phase; off-limits to the worker | Specifier |

If a worker can edit the acceptance tests, a run can pass by weakening the check
instead of meeting it. Workers may add tests next to their code; those are output,
not acceptance.

## Constraints checklist

Close the decisions an agent would otherwise make silently and differently on
every run:

- Language standard and compilers that must keep working.
- Warning policy, and whether warnings are errors.
- Sanitizer configuration the tests run under.
- Dependency manifest, and whether adding to it requires approval.
- API/ABI stability boundaries: which headers are contract, which are internal.
- Performance budgets, where correct-but-slower is a defect.
- Concurrency/ownership discipline, where the invariant is not obvious from code.

Without this, one run adds a dependency, another redesigns an interface, and you
are comparing engineering decisions rather than judging the task.

## Phased roadmap

- Split work into phases that can be implemented and judged one at a time.
- Fix each phase's interface before its implementer starts.
- Size each phase for the weakest role that will execute it — role selection and
  packet sizing are owned by
  [delegation-and-handoff.md](delegation-and-handoff.md).
- Keep each phase's required final state checkable by the acceptance suite.

Roadmap ownership depends on which skills are wired together. When
`apply-spec-driven-development` is in use, it owns discovering and maintaining
`specs/roadmap.md`; the planner then consumes the approved phases and decomposes each into packets
sized for the executing role, without rewriting the approved spec. When that skill is absent, the planner owns the roadmap end to end and
maintains it as a living artifact. Either way, the rules above apply to
whoever produces the phase list.

## Acceptance scoreboard declaration

One command decides the outcome. This heading declares that single command; the results table
(attempt log / run ledger) is owned by [configuration-and-measurement.md](configuration-and-measurement.md).
Every run ends in the same invocation returning the same exit status, a result you can record
next to a token count. Each phase declares:

```markdown
## Scoreboard — <phase name>

- **Command (repo-relative)**: <single wrapper invocation that configures,
  builds, and tests — e.g. a preset or script that provably rebuilds>
- **Adjudicates**: <phase acceptance criteria, one line each>
- **Run per attempt**: exactly once, as the final action
- **Recorded with**: the attempt's exit status, matching the `outcome` column of
  the attempt log
```

Checklist before first use:

- Does the command actually rebuild? A bare test-runner call happily tests stale
  binaries after a source or build-system change — a failure the worker will not
  notice and you will not see in a green result.
- Is it the same invocation for every attempt of the phase?
- Are the acceptance tests immutable to the worker (write-allowlist where the
  harness supports it; review obligation where it does not — see
  [delegation-and-handoff.md](delegation-and-handoff.md))?
- Does it return a verdict you can compare across runs without interpretation?

## One score-adjudication run per attempt

The scoreboard run — the full adjudication whose exit status you record — ends
the attempt. Rules:

- Run it **exactly once** per attempt, as the final action. The exit status it returns
  **is** the recorded outcome — the scoreboard runs exactly once, so what is recorded is
  the pre-repair verdict; a repaired change is a new attempt with its own run and outcome.
- Report the result upward whether it passes or fails; do not repair after it.
- Whether to repair, and how to split the repair, is the planner's decision —
  redelegate to a fresh worker rather than fixing in place (see
  [delegation-and-handoff.md](delegation-and-handoff.md)).
- Targeted checks during implementation are unlimited; the scoreboard is not.

Without that boundary, a worker reacting to a red result edits and rebuilds
indefinitely; iterations are expensive and wall clock disappears before anyone
notices, while one scoreboard run keeps the failure cheap and legible.

## Targeted checks vs the full scoreboard

Distinguish the inner development loop from the adjudication:

| | Targeted checks | Full scoreboard |
|---|---|---|
| Frequency | As often as useful while working | Exactly once, as the final action |
| Scope | The files/targets being changed | The whole project contract |
| Cost | Cheap (fast build subset, focused tests) | Full build + full suite |
| Purpose | Fastest feedback for the implementer | Result worth recording |
| Permission | Always allowed; encourage it | Part of the end condition |

For C++ projects this matters: forbidding compile-and-test during development makes the
compiler useless as a tool, while repeated full runs invite a rerun-and-fix spiral;
permit the targeted commands; gate the scoreboard to once.

## Measuring by role

Context pressure relocates rather than disappearing: shrinking worker sessions
inflate the orchestrator's, so plan and measure planner and worker separately.
Which metrics to record, the `outcome` column (the pre-repair result by
construction — the scoreboard runs exactly once per attempt, so there is no
separate first-pass column here), and controlled-comparison procedure are owned
by [configuration-and-measurement.md](configuration-and-measurement.md); this file
declares only the command, not duplicate result columns.

## Start clean without touching existing dirty state

Every run is a clean start at a declared revision: fresh context per attempt, no
conversational or environmental state carried in — and the run may touch only
state it created itself. Dirty-tree assessment, scratch worktrees, parking, and
restoration are operational details owned by the checklist in
[permissions-and-local-inference.md](permissions-and-local-inference.md#clean-starts-without-destroying-dirty-work);
this file fixes the contract: if the tree is dirty and no worktree is provided,
abort and report — never stash, revert, `checkout .`, `clean`, or discard user
state as a run side effect.
