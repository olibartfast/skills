# Changelog Format

## Contents

- Keep a Changelog sections
- Tone and bullet rules
- Conventional Commit mapping
- Template

## Keep a Changelog sections

Use only sections with entries, in this order:

- Breaking Changes
- Added
- Changed
- Deprecated
- Removed
- Fixed
- Security

Omit empty sections. Never rename historical headings in `CHANGELOG.md`.

## Tone and bullet rules

- Write for users, not implementers.
- One logical change per bullet; consolidate follow-ups.
- Start with an action verb: `Add`, `Fix`, `Improve`, `Remove`, `Deprecate`.
- State the user-visible effect first, then scope if needed.
- Keep every bullet auditable with a short OID or PR/issue number,
  for example `(#412)` or `` `a1b2c3d` ``.
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
| `BREAKING CHANGE`, `!` (e.g. `feat!:`) | Breaking Changes | `major` |
| `deprecate:` or deprecation notice | Deprecated | `minor` or `patch` per policy |
| `remove:` | Removed | `major` if breaking, else `minor` |
| `security:` / vulnerability fix | Security | `patch` or `major` per severity |

Non-conventional messages require `git show --stat` inspection
before categorization.

## Template

```markdown
## [1.4.0] - 2026-11-25

### Added
- Add CSV export for billing reports with custom date filters (#412)

### Fixed
- Fix session timeout occurring prematurely during file uploads (#419)
```

For an undated draft, use `## [Unreleased]`.
Prepend above prior releases; leave history untouched.
