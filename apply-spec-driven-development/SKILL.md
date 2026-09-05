---
name: apply-spec-driven-development
description: Apply spec-driven development using project constitution artifacts (mission.md, tech-stack.md, roadmap.md) and per-feature specifications (requirements.md, plan.md, validation.md). Use when interviewing for requirements, defining validation before implementation, slicing work into thin phases, adopting specifications in a brownfield repository, keeping living specs synchronized, or replanning after integration feedback.
---

# Apply Spec-Driven Development

Specify work before building it. Anchor every feature in project constitution artifacts,
write validation before implementation, and keep the specification a living document that
travels with the code through integration.

## Boundary

- **This skill owns:** discovery, interviewing, requirements, thin-phase planning,
  validation design, living specification upkeep, and replanning after feedback.
- **design-ai-systems owns:** production AI/ML architecture — model selection, compute,
  serving, observability, governance. Invoke it when the feature itself is an AI system;
  then embed its outputs in this skill's artifacts.
- **orchestrate-ai-coding-workflows owns:** delegation, model routing, permissions, and
  measurement of AI coding execution. Use it to run the implementation tasks this skill defines.

## Artifact flow

Constitution → requirements → plan → validation (before implementation) → implement →
execute validation and record evidence → synchronize and integrate → replan.

### Project constitution (repository-level)

Create once under `specs/`, update when decisions change, keep short and stable:

- `specs/mission.md` — what the product is, who it serves, what it must never do.
- `specs/tech-stack.md` — languages, frameworks, key dependencies, and constraints
  (supported platforms, performance budgets, licensing) that plans must respect.
- `specs/roadmap.md` — thin, outcome-oriented slices in priority order plus status.

### Per-feature packet (created per increment)

- Feature directory: `specs/YYYY-MM-DD-feature-name/` (the first date is when the
  specification was created, not when it shipped).
- `requirements.md` — scope (in/out), user stories or acceptance criteria, constraints
  traced to the constitution, and open questions.
- `plan.md` — thin phases, the work each one delivers, and integration checkpoints.
- `validation.md` — how each requirement will be proven, **defined before implementation**.

## Workflow

1. **Interview before consequential assumptions.** When requirements could reasonably go
   two ways, ask targeted questions first. Record answers and any deliberate assumptions
   in `requirements.md` under open questions or scope notes.
2. **Select and isolate one phase.** Choose the next incomplete roadmap phase, create the
   dated feature directory, and use the repository's feature-branch or isolated-worktree
   convention so its specification and code form one reviewable change.
3. **Split in-scope from out-of-scope explicitly.** Anything deferred goes in out-of-scope
   with a pointer to the roadmap item that will pick it up. Silent scope is the failure mode.
4. **Slice work into thin phases.** Each phase ends with runnable, reviewable output and a
   working integration. Prefer a walk-before-run order: smallest correct behavior first,
   hardening and edge cases after.
5. **Write validation before code.** For each requirement, state the observable check
   (test, command, manual step, metric) that proves it. Keep requirements ↔ validation
   traceable, e.g. R-1 → V-1.
6. **Implement in task groups.** Per phase, list concrete tasks, distill each task's
   obligations from the relevant spec sections into the task or delegation packet, and
   verify acceptance criteria as tasks complete — not only at the end.
7. **Validate for real.** Run the defined checks against actual behavior (tests, builds,
   manual verification). Record evidence and dates in `validation.md`. If a check fails,
   fix or replan — never mark validated by aspiration. For controlled delegated attempts,
   follow `orchestrate-ai-coding-workflows` instead of rerunning its acceptance scoreboard.
8. **Keep the specification living on the same branch.** As implementation teaches you
   things, update requirements, plan, and validation in the feature commits — along with
   supporting docs. When a spec-code discrepancy appears, classify it: if the intended
   requirement remains correct, fix the code; if the discovery shows the requirement
   itself is wrong or incomplete, review and update requirements, plan, and validation
   with the reason recorded.
9. **Integrate and report.** Update `specs/roadmap.md` status, the changelog, and any
   user-facing docs with the release. Note deviations between spec and shipped behavior.
10. **Replan after feedback.** When integration, review, or usage reveals a wrong early
   decision, revise the affected artifacts and slice again — replanning is expected, not failure.

## Proportional use

Scale ceremony to risk. Trivial fixes (typos, comment tweaks, one-line mechanical changes)
need no packet. Small contained changes may get a single short spec note with validation
in the PR. Use full packets when the work is multi-phase, touches public behavior or
architecture, or reversibility is low. Never skip the validation-before-code step for
non-trivial changes; skipping paperwork is fine, skipping thought is not.

## Deliverable

A completed run of this skill produces:

- Constitution artifacts that are current (or a deliberate decision that they are unchanged).
- A feature packet under `specs/YYYY-MM-DD-feature-name/` with `requirements.md`,
  `plan.md`, and `validation.md` (traceable to requirements) reflecting what was actually built.
- Executed validation evidence with dates in `validation.md`.
- Updated roadmap, changelog, and docs for anything shipped.
- A short summary of deviations and any replans performed.

## References

- [artifact-templates.md](references/artifact-templates.md) — skeletons for constitution and feature packet files.
- [interviewing-and-requirements.md](references/interviewing-and-requirements.md) — question patterns, scope splitting, assumption logging.
- [thin-phase-planning.md](references/thin-phase-planning.md) — slicing work, phase sizing, task groups.
- [validation-and-traceability.md](references/validation-and-traceability.md) — requirement-to-check tracing and evidence formats.
- [brownfield-adoption.md](references/brownfield-adoption.md) — introducing specs into an existing codebase incrementally.
- [integration-spec-sync-and-replanning.md](references/integration-spec-sync-and-replanning.md) — living-spec updates, roadmap/changelog sync, replan triggers.
