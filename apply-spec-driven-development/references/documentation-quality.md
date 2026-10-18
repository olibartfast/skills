# Documentation Readability and Writing Quality

Use this guidance when drafting or revising feature specs, constitution artifacts,
validation evidence, handoff notes, changelogs, and user-facing documentation. It applies
to new text and to readability passes over documents that already exist.

## Goal

Improve the human readability and overall writing quality of the documentation.

Write for an experienced software engineer who should be able to understand the concepts,
architecture, and requirements without unnecessary cognitive overhead.

## Writing guidelines

- Prefer clear, natural technical language over identifier-heavy prose.
- Minimize the use of prefixed IDs in headings, paragraphs, and cross-references.
- Use descriptive names and introduce identifiers only when they provide value.
- Prefer meaningful headings that describe concepts rather than internal IDs.
- Explain concepts before introducing implementation details or dependencies.
- Use concise sentences, active voice, and well-structured paragraphs.
- Eliminate redundant explanations, repetitive references, and unnecessary jargon.
- Define specialized terminology and acronyms when first introduced.
- Use descriptive links to related documents and sections.
- Maintain consistent terminology and writing style across all documents.
- Preserve technical precision, completeness, and the intended meaning.
- Preserve normative language (MUST, SHOULD, MAY, etc.) and all requirements.
- Do not change architectural decisions, interfaces, implementation details, or acceptance
  criteria as part of a readability improvement.
- Never remove or rename identifiers required for traceability, tooling, automated
  validation, or external references.

The goal is not to eliminate identifiers, but to ensure they support the documentation
rather than dominate it.

## Editing procedure

Before editing, inspect the existing documentation and understand its structure and
conventions. Apply the improvements consistently throughout the relevant documents.

After editing, validate internal links, references, terminology consistency, and
preservation of requirements. Report any ambiguities that cannot be resolved without
changing technical meaning.

Focus on making the documentation read as if it were written by a skilled technical writer
working closely with the engineering team, rather than generated from a database of
requirements and identifiers.

## Applying the guidance to spec artifacts

- **Keep traceability IDs, but move them out of the reading path.** Stable IDs such as
  `R-1`, `D-1`, `V-1`, and `T-2` remain in requirement rows, decision records, evidence
  tables, and task lists. In prose, refer to the concept by name and add the ID only when
  a reader needs it to follow a cross-reference.
- **Write headings for concepts.** Prefer "Failure handling" or "Rollback and data
  compatibility" over "R-4" or "D-2". If an existing heading is a stable anchor used by
  links or tooling, keep the anchor and improve the visible wording around it.
- **Explain before detailing.** State the outcome and the reason before listing
  dependencies, interfaces, or implementation steps. A reader should not need to
  reconstruct the purpose from a table of identifiers.
- **Preserve normative force.** Readability edits must not soften, strengthen, or
  reinterpret MUST, SHOULD, MAY, acceptance criteria, thresholds, or scope boundaries.
- **Keep evidence literal.** Commands, results, dates, logs, and failure output are
  evidence; make them easier to locate without paraphrasing what was observed.
- **Record unresolved ambiguity.** If a sentence is unclear and the correct meaning cannot
  be established without changing technical intent, leave the requirement intact and raise
  the question in the document's open questions or the final report.
- **Update links with headings.** When a heading changes, update every internal link and
  referenced anchor in the same change.
- **Check the whole document set.** A readability pass is complete only when terminology,
  heading style, and cross-references are consistent across the affected documents, not
  just the edited paragraph.

## Readability pass checklist

- [ ] The purpose and audience are clear within the first few paragraphs.
- [ ] Concepts are explained before implementation details and dependencies.
- [ ] Headings describe concepts and remain useful as navigation.
- [ ] Prose carries the explanation; IDs appear where traceability needs them.
- [ ] Terminology and acronyms are defined once and used consistently.
- [ ] Internal links and anchors resolve, and descriptive link text identifies the target.
- [ ] Normative language, requirements, decisions, interfaces, and acceptance criteria are
      unchanged in meaning.
- [ ] Traceability, tooling, and externally referenced identifiers are intact.
- [ ] Redundancy, repetition, and unnecessary jargon have been removed.
- [ ] Remaining ambiguities are reported rather than silently resolved by a wording change.
