# Changelog Format

## Contents

- Keep a Changelog sections
- Tone and bullet rules
- Conventional Commit mapping
- Template
- Sources

## Keep a Changelog sections

Use only sections with entries, in this order:

- Added
- Changed
- Deprecated
- Removed
- Fixed
- Security

Omit empty sections. Never rename historical headings in `CHANGELOG.md`.

Use `### Breaking Changes` only as an extension when the existing
`CHANGELOG.md` already uses it (placed first). Otherwise mark breaking
entries inline with a `**BREAKING:**` prefix under `Changed` or `Removed`
to stay strict Keep a Changelog compliant.

## Tone and bullet rules

- Write for users, not implementers.
- One logical change per bullet; consolidate follow-ups.
- Start with an action verb: `Add`, `Fix`, `Improve`, `Remove`, `Deprecate`.
- State the user-visible effect first, then scope if needed.
- Keep every bullet auditable with a short OID or PR/issue number,
  for example `(#412)` or `` `a1b2c3d` ``.
- On disk, an existing `CHANGELOG.md` that omits hashes wins: match its
  style and put OID traceability in the chat report instead.
- Exclude internal-only work unless it changes requirements,
  performance, or behavior.
- Do not invent numbers, contributors, links, or dates.

Good:

- `Add CSV export for billing reports with custom date filters (#412)`
- `Fix session timeout occurring prematurely during file uploads (#419)`

Avoid:

- `Refactor uploader internals`
- `2x faster sync` (unless the commit or benchmark proves it)

## Conventional Commit mapping

| Prefix / footer | Section | Bump hint |
| --- | --- | --- |
| `feat:` | Added | `minor` |
| `fix:` | Fixed | `patch` |
| `perf:` | Changed | `patch` |
| `docs:`, `chore:`, `test:`, `ci:`, `refactor:` | Exclude unless user-facing | none |
| `BREAKING CHANGE`, `!` (e.g. `feat!:`) | Breaking Changes if used, else `Changed`/`Removed` with `**BREAKING:**` | `major` (`minor` on `0.y.z`) |
| `deprecate:` or deprecation notice | Deprecated | `minor` or `patch` per policy |
| `remove:` | Removed | `major` if public-facing, else `minor` (`minor` on `0.y.z`) |
| `security:` / vulnerability fix | Security | at least `patch` (`major` if breaking or severe) |

Non-conventional messages require `git show --stat` inspection
before categorization.

Pre-`1.0.0` note: on `0.y.z`, breaking changes bump `minor`
(`0.(y+1).0`) until an explicit `1.0.0` graduation. State the
assumption in the semver recommendation.

## Template

Versioned release goes below `## [Unreleased]`, above prior releases:

```markdown
## [Unreleased]

## [1.4.0] - 2026-11-25

### Added
- Add CSV export for billing reports with custom date filters (#412)

### Fixed
- Fix session timeout occurring prematurely during file uploads (#419)

[Unreleased]: https://example.com/compare/v1.4.0...HEAD
[1.4.0]: https://example.com/compare/v1.3.0...v1.4.0
```

For an undated draft, use `## [Unreleased]` with no date.
When cutting a release, move graduated items from `[Unreleased]` into the
new version block. Update bottom comparison links when the file uses them.
Prepend above prior releases; leave history untouched.

## Sources

Based on Keep a Changelog (<https://keepachangelog.com/>),
Conventional Commits (<https://www.conventionalcommits.org/>),
Semantic Versioning (<https://semver.org/>), and the Agent Skills
specification (<https://agentskills.io/specification>), accessed 2026-11-25.
Structure informed by `ComposioHQ/awesome-claude-skills/changelog-generator`
(user-facing translation pattern) and `alirezarezvani/claude-skills/changelog-generator`
(Conventional Commit parsing and semver-bump separation). Adapted into
operational instructions rather than reproduced.
