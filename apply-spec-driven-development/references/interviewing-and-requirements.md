# Interviewing and Requirements for Spec-Driven Development

How to gather intent before writing spec artifacts, and how to decide when
a question is worth asking versus when an assumption is safe to record.

## Contents

1. [Golden rule: interview before you draft](#golden-rule)
2. [Constitution interview](#constitution-interview)
3. [Feature interview](#feature-interview)
4. [The material-ambiguity test](#material-ambiguity-test)
5. [Evidence vs. inference (brownfield)](#evidence-vs-inference)
6. [Explicit non-choices](#explicit-non-choices)
7. [Stopping criteria before drafting](#stopping-criteria)

## Golden Rule

Interviewing is a guardrail against confident invention. Read available
material first (README, product brief, issues, meeting notes, existing
code), form targeted questions, and ask them **before** writing any spec
file. If an unanswered question could materially change the feature, ask —
do not silently encode it into code.

Every claim you carry forward must be one of three things, and labeled as
such:

- **Finding** — directly observed and citable (a file, a URL, a stated
  stakeholder decision).
- **Inference** — derived from evidence; plausible but confirmable.
  Label it, state the basis, and confirm with a human when material.
- **Assumption** — accepted without evidence, usually about the future.
  Record it with a basis; promote it to a question if material.

## Constitution Interview

Run once per project (or reconstruction), before writing
`mission.md`, `tech-stack.md`, and `roadmap.md`. Three question clusters:

1. **Mission** — Who is the product for? Which problem matters most? What
   does success look like (observable, ideally measurable)? Who is it
   explicitly *not* for?
2. **Technical boundaries** — For each area (language, framework, data
   store, tests, tooling), ask: what is **fixed** (unmovable, with the
   reason), what is **preferred** (follow unless recorded otherwise), and
   what is genuinely **open** (decide per feature)? Also ask what is
   explicitly *excluded* and why (see
   [non-choices](#explicit-non-choices)).
3. **Delivery sequence** — What is the first end-to-end slice that proves
   the stack and delivers value? What must precede it? What is deferred?
   Push toward thin, independently reviewable phases rather than broad
   milestones like "build the dashboard".

Cross-check the answers against the source material; contradictions (e.g.
a stated preference that existing code contradicts) become labeled
questions, not settled facts.

## Feature Interview

Run before drafting each feature packet, after selecting one roadmap
phase. Grouped questions let the human resolve product and engineering
ambiguity in one pass. Three clusters:

1. **Scope** — What data enters and leaves the feature? Which behaviors
   and states are included? Which states (empty, invalid, failure) are
   handled inside this phase, and which are deferred? What is explicitly
   out of scope?
2. **Decisions** — Which storage, API shape, validation, navigation, and
   UX choices must be fixed now? Record each answer as a decision
   `[D-n]` with its rationale, especially where it touches the
   constitution.
3. **Context** — Which existing patterns, tone rules, compatibility
   needs, or operational constraints shape the work? For brownfield
   items, ask the source: is this a document you can show me, or your
   understanding?

Afterward, cross-check answers against `mission.md` and `tech-stack.md`;
flag any feature decision that would loosen a constitution boundary.

## Material-Ambiguity Test

Deciding *ask vs. label as assumption* comes down to consequence, not
confidence. Ask a question when **all** of these hold:

1. **Consequential** — the answer could change the feature's behavior,
   design, data handling, security, compatibility, or cost (do it again
   later / migrate data / rewrite an interface).
2. **One-shot** — getting it wrong now is expensive to reverse or will be
   baked in by dependent work.
3. **Answerable** — there is plausibly someone or something that can
   settle it.

Label it as a recorded assumption `[A-n]` when it is *low-impact* (easily
reversible, cosmetic, local), or when no answer is realistically
available and the default is the safest reasonable choice.

Bright lines — **always ask** — include anything touching data retention,
security, privacy, externally visible contracts, or breaking changes to
existing users. Defaulting these silently is the classic failure mode of
agent-planned work; a plausible default that survives a first demo can
still be the wrong product decision.

If you cannot tell whether an ambiguity is material, treat it as
material: the cost of one question is lower than the cost of a wrong
commit.

## Evidence vs. Inference

On an existing codebase, the first task is reconstruction. Rules:

- **Cite or label.** A documented boundary ("tests run via the standard
  test command; see config file X") is evidence. A reconstructed
  boundary ("this looks like it uses library Y") is an inference — label
  it and confirm before treating it as a constraint.
- **Behavior outranks documentation.** When a document and the
  implementation disagree, the executed tests and current behavior are
  the evidence; the document is a draft until reconciled.
- **Beware fluent summaries.** An agent can summarize a codebase
  convincingly while missing an operational constraint (cron jobs,
  migrations, deployment quirks, licensing). Confirm anything that would
  hurt if wrong.
- **Spec only what is active.** Roadmaps come from unfinished work; do
  not retro-specify stable history. Constitution updates follow adoption,
  not a big-bang rewrite.

## Explicit Non-Choices

Non-choices ("no ORM in the first release", "no client-side framework")
are recorded decisions to *not* use something, with the reason. They earn
their place because:

- They prevent scope expansion driven by a familiar dependency's
  convenience — including by agents that reach for what they know.
- They make intent inspectable: a reviewer sees the boundary was
  deliberate, not accidental.
- They transfer across agent sessions, where a plain prohibition in a
  single prompt would be lost.

Format: the excluded option, the rationale, and — where useful — the
condition that would justify revisiting ("revisit if X"). Record
non-choices in `tech-stack.md` (cross-feature) or in a feature's
requirements when local.

## Stopping Criteria

Start writing the spec only when **all** of the following hold:

- [ ] Mission, technical boundaries, and first phase exist as constitution
      files (or this feature is a reconstruction that explicitly defers
      them, with the deferral recorded).
- [ ] One roadmap phase is selected; scope, decisions, and context
      clusters have been asked and answered.
- [ ] Every material ambiguity has been answered *or* consciously labeled
      as an assumption `A-n` with its basis (no silent defaults).
- [ ] In-scope and out-of-scope lists are draftable, and no known stakeholder
      disagreement about them remains.
- [ ] Constitution conflicts this feature would cause are resolved or
      recorded as open questions.
- [ ] Context items are findings or labeled confirmable inferences.
- [ ] Validation is co-designed: you can state, in advance, what evidence
      would prove each requirement.

Anything not satisfied becomes one of: a question to ask, a decision to
make, or a labeled assumption in the spec — never an undocumented gap.
If the change is microscopic (typo, one-line fix), skip the full
interview and use a short issue plus a test instead.
