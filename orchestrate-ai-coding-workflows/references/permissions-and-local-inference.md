# Permissions and Local Inference

Templates and checklists for enforcing boundaries in a coding-agent workflow and
for sizing work so it succeeds on the weakest participant. Harness-agnostic where
possible; harness-specific mappings only where verified.

Source basis: [AI Coding Workflows: From Cloud to Local](https://olibartfast.ninja/blog/ai-coding-workflows-cloud-to-local.html),
adapted into operational templates.

## Contents

- Deny-by-default permissions
- Read-only review role
- Clean starts without destroying dirty work
- Advisory vs. enforced boundaries
- Capability to constraint mapping (pointer)
- Sizing work for the weakest participant
- Local inference and egress auditing

## Deny-by-default permissions

Rule: an agent definition that matters is an allowlist. A permit-everything-except
rule still leaves the agent free to rewrite the manifest, presets, acceptance
tests, and its own definition — every input the comparison depends on.

Checklist:

- Start each agent definition with `*`: deny for edits and commands.
- Allow only the exact repo-relative paths the verified brief names.
- Allow only the project's own configure/build/test invocations — pattern-glob them
  throughout so the preset stays authoritative.
- Deny web-fetch, web-search, and package installation.
- Restrict generated trees and vendored directories to read-only: keep
  read/list of `build/` and vendored paths allowed where inspection is needed
  (review must see what was actually built and why); deny only write/edit and
  command execution there.
- Regenerate the permission block per phase so the brief and the permission block
  always name the same paths.
- Require whole-file writes rather than anchor-based edits; a mismatched anchor
  retried forever is the most common small-model failure.

OpenCode-style template (path-level write and command rules; see the harness
mapping below — Claude Code achieves a partial equivalent with session/project
settings `Edit(path)` rules). In OpenCode's permission blocks the **last
matching rule wins**, so the catch-all must come first and specific allowances
after it. This ordering pattern does **not** translate to Claude Code: there,
deny rules always outrank allow rules, so a deny-all catch-all followed by
allow entries would deny everything. In Claude Code the equivalent is
allowlist-style configuration plus **targeted protected-path deny rules** for
the specific paths you must make immutable (specs, presets, acceptance tests,
agent definitions) — not deny-all-then-allow:

```yaml
---
description: Implementer for one well-specified phase.
mode: subagent
steps: 12
permission:
  edit:
    "*": deny                    # catch-all first: last match wins
    "src/phase_x/foo.cpp": allow
    "src/phase_x/CMakeLists.txt": allow
  bash:
    "*": deny                    # catch-all first: last match wins
    "cmake --preset ci": allow
    "cmake --build --preset ci*": allow
    "ctest --preset ci*": allow
    "cmake --workflow --preset ci": allow
  webfetch: deny
  websearch: deny
---
```

The glob/list rules match paths and commands, not tree traversal: a path
allowlist does not stop the agent from *reading* anything else, and it should
not — review and implementation need repository inspection. Keep the write
and command gates tight; keep reads broad.

Harness mappings (verify against your version before committing; these details
are version-sensitive):

| Lever | Claude Code | Codex | OpenCode |
|---|---|---|---|
| Write scope | per-path via session/project settings `Edit(path)` allow/deny rules; deny always outranks allow (no deny-all-then-allow ordering; use targeted protected-path denies instead). Rules are inherited by subagents but are not distinct per-phase subagent allowlists | coarse (workspace) | fine (per-path allow/deny, per-agent; last match wins) |
| Command boundary | coarse tool allowlist | `sandbox_mode`, MCP allowlists | per-command `bash` rules |
| Step ceiling | `maxTurns` is per-invocation and returns partial output; the parent owns termination across invocations | no documented per-agent cap — parent must enforce | `steps` |
| Web tools off | `disallowedTools: WebFetch, WebSearch` | sandbox + no network | `webfetch`/`websearch: deny` |

Avoid hard-coding model identifiers in examples: read the served model ID from the
runtime; generation numbers age, capability tiers do not.

## Read-only review role

A reviewer agent is trusted about work from models you would not trust
unsupervised — so its write capability must be zero, not discouraged.

Checklist:

- Enforce read-only in configuration, not prose: denied edit/command tools, a
  read-only sandbox mode, or a deny-all permission block.
- Grant broad read access; review needs the changed paths plus the interfaces and
  acceptance suite they touch.
- Output verdicts only: a findings file the planner consumes, written by the
  planner, not by the reviewer.
- Reject-review is a planner responsibility; the reviewer never repairs and never
  hands patches to the implementer.

## Clean starts without destroying dirty work

Every controlled run starts from a known revision. Cleanup is planner-owned
(or human-owned); an agent may destroy only state it created itself, in paths
it can name, and must abort and report on anything unexpected.

Checklist:

- Before a run, record `git status --porcelain` and the branch name.
- If the tree is dirty, do not manipulate the user's pre-existing state
  automatically. Prefer isolated scratch worktrees (`git worktree add`
  under a run-owned directory); in-tree runs require a clean tree, left to the
  planner or the human to arrange.
- A run may destroy only state it created itself, scoped to the paths it created;
  on unexpected or concurrent changes, abort and report rather than proceeding.
- Return to the exact starting commit after a run; verify with `git status` and
  the recorded SHA, not by assumption.
- Simplest for in-tree runs: omit stash handling entirely — nothing to restore,
  nothing to lose.
- If stashing is unavoidable, make it explicit opt-in: `git stash push
  --include-untracked` with a named stash message, then restore by looking the
  entry up — run `git stash list` to find the `stash@{N}` index of the named
  entry and pop that exact ref (`git stash pop stash@{N}`). A message alone is
  not a valid pop argument. Then verify the working tree matches the recorded
  `--porcelain` output (`git status`) before considering the restore done.
  Never `git checkout -- .`, `git reset --hard`, `git clean`, `git stash clear`,
  or an un-targeted `git stash pop` on pre-existing state: those destroy or
  mix in concurrent and user changes.
- Keep the turn-by-turn rule here too: fresh context per task — carrying a long context into the next task degrades quality unnoticed.

## Advisory vs. enforced boundaries

Anything in a prompt or an agent-definition body is persuasion; only the
harness-applied portion of an agent definition is enforcement. Observed in
controlled runs: the same instruction was obeyed in one phase and partially
ignored in the next, with no other change.

Classification rule:

| Want | Put it in |
|---|---|
| Reachable tools, write scope, command scope, step budget, model | Harness-enforced configuration |
| Style, naming, how to implement | The brief (advisory is fine) |
| "Do not touch the acceptance tests" | Permission block if the harness supports it; otherwise a review check, never prose only |
| "Stop after the scoreboard run" | Parent-workflow termination logic if no per-agent ceiling exists |

Audit checklist for any agent definition:

- For each safety-relevant clause, ask: does the harness refuse, or does it merely
  hope? Anything marked hope must be backstopped by review or by the parent.
- Where the harness is coarse, compensate: no per-agent step ceiling (Codex) or
  invocation-only `maxTurns` (Claude Code) means the parent owns termination;
  no per-path write enforcement (Codex) means "these paths and no others" is a
  review obligation, not a setting. See the harness table above.

## Capability to constraint mapping

Each constraint counters a specific observed failure; the full pairing catalogue
(read-before-edit, scoreboard-run-once, contract artifacts, metrics) lives in
`workflow-contract.md` and `configuration-and-measurement.md`. Permissions-owned rows:

| Constraint | Failure it prevents |
|---|---|
| Write allowlist | Editing specs, tests, manifest, or presets to match what was built |
| Command allowlist + web/search off | Package installs, network fetches, bypassing project presets |
| Step ceiling | Retry loops running until context is exhausted |
| Whole-file writes | Mismatched anchor patch retried forever |
| Read-only review role | A model trusted to review code while untrusted to write it |

## Sizing work for the weakest participant

Sized for the weakest participant: splitting an oversized phase costs a capable
model nothing; a small model skipping the earlier half of its context is
unfixable at model level. Permissions-relevant sizing:

- On weak tool-calling, permit only whole-file writes, one permitted command
  family, and a hard step ceiling.
- Use quantisation sized to available memory rather than swapping models per job.
- The permission block must name the same paths as the brief; the full delegation
  packet requirements (named paths, required final state, scoreboard command,
  stop condition) live in `delegation-and-handoff.md`.

## Local inference and egress auditing

Local serving removes metered cost, works offline, and keeps source on your
hardware — but closes one egress path, not all of them. Audit checklist:

- Enumerate every outbound path: web-fetch and search tools, package managers,
  MCP servers, telemetry, and update checks in the harness and its plugins.
- For each path: disabled, allowlisted to explicit endpoints, or accepted risk —
  recorded in the run notes, not assumed.
- Verify by observation once (system-level egress or network logs), not by
  reading the tool list alone.
- Keep the audit with committed configuration so a later tool addition cannot
  silently re-open a channel.
- New tooling added for one phase re-audits the whole list; the model being local
  says nothing about its harness.
