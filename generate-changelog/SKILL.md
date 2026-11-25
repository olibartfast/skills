---
name: generate-changelog
description: Generate user-facing changelogs and release notes from git history following Keep a Changelog format. Use when creating CHANGELOG.md entries, drafting release notes, summarizing commits since the last tag, recommending a semver bump, or preparing a versioned release.
---

# Generate Changelog

Turn git history into clean, traceable user-facing release notes.
Draft only; publishing a release or tag is a separate authorized operation.

## When to Use / When Not To

Use when asked to create a changelog, update `CHANGELOG.md`, draft release notes,
summarize what shipped since a tag or date, or recommend the next version.

Do not use for single-PR descriptions, general `git status` debugging,
or as implicit authorization to commit, tag, push, or publish a release.

## Inspect Before Acting

Read repository instructions, contribution guidance, and existing
`CHANGELOG.md` conventions before generating anything.

Start read-only:

```bash
git status --short --branch
git tag --sort=-creatordate | head -n 20
git log --oneline -20 --decorate
```

If `CHANGELOG.md` exists, match its heading style, link format, and tone.
Do not rewrite historical entries.

Preserve unrelated work. Do not stash, reset, switch branches, or alter
history to generate a changelog.

## 1. Resolve the Range

- Use the user-supplied range, tag, commit, or date when given.
- Otherwise default to `<latest_tag>..HEAD` when tags exist.
- With no tags, ask for a range or agree on a default such as last 30 commits.
- Record the resolved base, head, and their full OIDs with `git rev-parse`.
- Fetch only when permitted; stale remote refs must not silently define the range.

## 2. Gather and Verify Changes

Collect commits in range:

```bash
git log <base>..<head> --no-merges --pretty=format:'%H | %s | %an | %ad' --date=short
```

- For vague messages (`fix stuff`, `wip`, `updates`), inspect
  `git show --stat <oid>` or the diff before summarizing.
- Consolidate multiple commits for one feature or fix into one entry.
- Drop revert/reland flip-flops resolved inside the range.
- Filter internal noise (chore, ci, test-only, formatting, internal refactor)
  unless it changes user behavior, requirements, or performance.
- Keep every bullet traceable: retain the short OID or PR/issue reference
  behind each entry so the draft can be checked. See
  [changelog format](references/changelog-format.md).

## 3. Categorize and Recommend Version

Group only non-empty sections, in this order:

1. Breaking Changes (triggers `major`)
2. Added — new features (triggers `minor`)
3. Changed — behavior or performance changes
4. Deprecated
5. Removed
6. Fixed — bug fixes (triggers `patch`)
7. Security

Semver recommendation from Conventional Commits and footers:

- `BREAKING CHANGE` or `!` footer/prefix -> `major`
- `feat:` -> `minor`
- `fix:`, `perf:` without breaking markers -> `patch`
- No user-facing changes -> no bump; state that explicitly.

In monorepos, filter by package path when requested and label
package-scoped entries; do not mix unrelated package histories silently.

## 4. Write the Output

- Start each bullet with an action verb (`Add`, `Fix`, `Improve`).
- Describe user impact, not internal symbols or function names.
- Append `(PR #123)` / `(#123)` only when present in the source commit.
- Never invent metrics, dates, contributors, or links.
- Prepend the new `## [version or Unreleased] - YYYY-MM-DD` section above
  prior releases. Do not edit prior sections.
- Offer machine-readable or GitHub-release variants only when requested.

Example heading structure:

```markdown
## [Unreleased]

### Added
- Add CSV export for billing reports (#412) — `a1b2c3d`

### Fixed
- Fix session timeout during large uploads (#419) — `e4f5g6h`
```

Full template and tone rules: [changelog format](references/changelog-format.md).

## Deliverable

Report the resolved range and OIDs, the recommended semver bump with reason,
the draft location, and any ambiguous commits that need human confirmation.
State that the draft is uncommitted and unpublished unless the user
explicitly authorized writing, committing, tagging, or releasing.

## Source

Based on Keep a Changelog (<https://keepachangelog.com/>),
Conventional Commits (<https://www.conventionalcommits.org/>),
Semantic Versioning (<https://semver.org/>), and the Agent Skills
specification (<https://agentskills.io/specification>), accessed 2026-11-25.
Structure informed by `ComposioHQ/awesome-claude-skills/changelog-generator`
(user-facing translation pattern) and `alirezarezvani/claude-skills/changelog-generator`
(Conventional Commit parsing and semver-bump separation). Adapted into
operational instructions rather than reproduced.
