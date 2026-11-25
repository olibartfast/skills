---
name: generate-changelog
description: Generate user-facing changelogs and release notes from git history following Keep a Changelog-style format. Use when creating CHANGELOG.md entries, drafting release notes, summarizing commits since the last tag, recommending a semver bump, or preparing a versioned release.
---

# Generate Changelog

Turn git history into clean, traceable user-facing release notes.
Draft only; publishing a release or tag is a separate authorized operation.

## When to Use / When Not To

Use when asked to create a changelog, update `CHANGELOG.md`, draft release notes,
summarize what shipped since a tag or date, or recommend the next version.

Do not use for single-PR descriptions, general `git status` debugging,
or as implicit authorization to commit, tag, push, or publish a release.
Editing `CHANGELOG.md` on disk (left unstaged) is allowed when the user asks
to create or update it; `git commit`, `git tag`, `git push`, and `gh release`
always require separate explicit authorization.

## Inspect Before Acting

Read repository instructions, contribution guidance, and existing
`CHANGELOG.md` conventions before generating anything.

Start read-only:

```bash
git status --short --branch
git rev-parse --is-shallow-repository
git describe --tags --abbrev=0
git log --oneline -20 --decorate
```

If `CHANGELOG.md` exists, its heading style, link format, and tone win
over this skill's defaults. Do not rewrite historical entries.

Preserve unrelated work. Do not stash, reset, switch branches, or alter
history to generate a changelog.

## 1. Resolve the Range

- Check `git rev-parse --is-shallow-repository`; if `true`, warn that tags
  or commits may be missing before proceeding.
- Use the user-supplied range, tag, commit, or date when given.
- Otherwise resolve the latest reachable release tag on the current branch
  (`git describe --tags --abbrev=0`) and use `<latest_tag>..HEAD`. Ignore
  non-release tags (e.g. `nightly-*`, `deploy-*`) unless they match repo
  conventions.
- With no reachable tags, ask for a range or agree on a default such as
  the last 30 commits.
- Record the resolved base, head, and their full OIDs with `git rev-parse`.
- Fetch only when permitted; stale remote refs must not silently define the range.

## 2. Gather and Verify Changes

Collect commits, trailers, and merge context in range:

```bash
git log <base>..<head> --no-merges --pretty=format:'%H | %ad | %an | %s %(trailers:only,unfold)' --date=short
```

- If the repo uses merge-commit PRs rather than squash merges, also check
  `git log <base>..<head> --merges --oneline` so PR references (`#123`)
  are not lost.
- For vague messages (`fix stuff`, `wip`, `updates`) or suspected breaking
  changes, inspect `git show --stat <oid>` and full bodies
  (`git show -s --format=%B <oid>`) before summarizing. Explicitly check
  footers: `git log <base>..<head> --grep='BREAKING CHANGE' -F`.
- Consolidate multiple commits for one feature or fix into one entry.
- Drop revert/reland flip-flops resolved inside the range.
- Filter internal noise (chore, ci, test-only, formatting, internal refactor)
  unless it changes user behavior, requirements, or performance.
- Keep every bullet traceable: retain the short OID or PR/issue reference
  behind each entry so the draft can be checked. See
  [changelog format](references/changelog-format.md).

## 3. Categorize and Recommend Version

Group only non-empty sections, in this order:

1. Added — new features (triggers `minor`)
2. Changed — behavior or performance changes
3. Deprecated
4. Removed — public removals (triggers `major` if breaking)
5. Fixed — bug fixes (triggers `patch`)
6. Security (triggers at least `patch`)

Use a `### Breaking Changes` section only when the existing `CHANGELOG.md`
already uses it. Otherwise surface breaking entries under `Changed` or
`Removed` with a `**BREAKING:**` prefix.

Semver recommendation from Conventional Commits and footers:

- `BREAKING CHANGE` or `!` footer/prefix -> `major` (`0.(y+1).0` if the
  latest tag is `0.y.z`, unless the repo has declared `1.0.0` graduation;
  state the assumption explicitly).
- `feat:` -> `minor`
- `fix:`, `perf:`, `security:` without breaking markers -> `patch`
- `remove:` of a public API -> `major` (`minor` on `0.y.z`)
- No user-facing changes -> no bump; state that explicitly.

In monorepos, filter by package path when requested and label
package-scoped entries; do not mix unrelated package histories silently.

## 4. Write the Output

- Start each bullet with an action verb (`Add`, `Fix`, `Improve`).
- Describe user impact, not internal symbols or function names.
- Append `(#123)` only when present in source commits or merge commits.
  Include short OIDs (`` `a1b2c3d` ``) unless an existing `CHANGELOG.md`
  omits hashes — then match the file's style on disk and list OID
  traceability in the chat report instead.
- Never invent metrics, dates, contributors, or links.
- For an undated draft, update or create `## [Unreleased]` (no date) at the
  top. For a versioned release, place `## [X.Y.Z] - YYYY-MM-DD` directly
  below `## [Unreleased]` (moving graduated unreleased items into it when
  cutting a release) and above prior releases.
- Update bottom reference-style comparison links (`[Unreleased]`, `[X.Y.Z]`)
  when `CHANGELOG.md` uses them. Never rewrite historical release notes.
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
whether the draft was written to `CHANGELOG.md` (left unstaged) or is
chat-only, and any ambiguous commits that need human confirmation.
State that the draft is uncommitted and unpublished unless the user
explicitly authorized committing, tagging, pushing, or releasing.
