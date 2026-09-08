---
name: manage-gitflow-workflow
description: Manage Gitflow feature, release, and hotfix branches with explicit merge destinations, release tags, and safe integration checks. Use when working in a Gitflow repository, choosing between Gitflow and trunk-based development, preparing a versioned release, propagating a production hotfix, or reviewing branch and release policies.
---

# Manage Gitflow Workflow

Use Gitflow to separate ongoing development, release stabilization, and production
repairs when the repository's release model calls for it. Adapt branch names and
integration mechanics to existing policy; do not impose a new workflow silently.

## Decide Whether Gitflow Fits

Atlassian describes Gitflow as a legacy workflow and recommends trunk-based
development for modern continuous development and DevOps. Long-lived branches
increase divergence, merge effort, and CI/CD complexity.

- Use Gitflow when the team already follows it or explicitly needs scheduled,
  versioned releases with a stabilization period while future development continues.
- Prefer considering trunk-based development for frequent production delivery with
  short-lived branches and no separate stabilization requirement.
- Do not migrate branch topology as a side effect of an ordinary feature or fix.
- Multiple supported production versions need an explicit maintenance/backport
  policy; the basic two-long-lived-branch model does not define one.

## Inspect Before Acting

Read repository instructions, contribution guidance, CI configuration, release
automation, branch protections, and recent pull requests where accessible.
Establish the production branch, integration branch, active release branch,
remote, version/tag convention, merge strategy, and required checks.

Start with read-only inspection:

```bash
git status --short --branch
git diff
git diff --cached
git branch -avv
git remote -v
git log --graph --decorate --oneline -30
git tag --list
```

Remote-tracking refs may be stale. Fetch the intended remote when permitted,
then compare local and remote tips before choosing a base. Never assume the
remote is named `origin` or that `main` is the deployed production revision.
If production has not deployed the current production-branch tip, confirm the
correct hotfix base and release strategy before proceeding.

Preserve unrelated work and existing staging. Do not auto-stash, discard changes,
or switch branches over in-progress work. Use an agreed isolated worktree or ask
when local changes conflict with the operation. Stop if a merge or rebase is
already in progress and its ownership is unclear.

## Branch Contract

Names below are conventions, not requirements. Map `main` to the repository's
production branch (possibly `master`) and `develop` to its integration branch.

| Branch | Base | Purpose | Required destinations |
| --- | --- | --- | --- |
| `main` | Existing production history | Official released versions | Version tags identify released commits |
| `develop` | `main` at initial setup | Completed work for upcoming releases | Supplies release branches |
| `feature/<name>` | Current `develop` | One feature or non-urgent development change | `develop`, not directly `main` |
| `release/<version>` | Selected `develop` commit | Stabilization, release metadata, documentation, bug fixes | `main` and `develop` |
| `hotfix/<name>` | Confirmed production baseline, normally `main` | Urgent production repair | `main` and `develop`, or `main` and the active release as described below |

## Execute the Appropriate Lifecycle

### Initialize Only When Requested

Confirm Gitflow adoption and branch names first. If `develop` does not exist,
create it explicitly from the confirmed production branch, not arbitrary `HEAD`.
Creating a branch does not create an empty history. Publishing it and configuring
protections or CI are separate authorized operations.

Plain Git is sufficient. The optional `git flow` extension is not built into Git;
do not install or initialize it automatically. Inspect its configuration and
implementation before using `finish`, which may merge, tag, and delete branches
as a compound operation.

### Feature

1. Create a short-lived feature branch from the verified current integration tip.
2. Implement and test the scoped change. Keep unrelated work out of its commits.
3. Review the full branch diff against `develop`, not just its latest commit.
4. Integrate through the repository's approved review and CI path into `develop`.
5. Verify integration before deleting the feature branch with authorization.
   Features reach production through a release, not a direct feature-to-main merge.

### Release

1. Confirm scope, version, and the exact tested `develop` commit to release.
2. Cut `release/<version>` from that commit. Freeze feature scope; allow only
   stabilization fixes, documentation, and release preparation on this branch.
   Continue next-release features separately on `develop`.
3. Run release checks, update version/changelog artifacts as required, and review
   the complete production-target diff. Include any intervening production hotfixes
   without pulling unrelated next-release features into the release branch.
4. Integrate the approved release into `main` through the required merge/PR process.
   Validate the resulting production commit, not just the pre-merge branch tip.
5. Tag that exact production commit using the agreed version and signing policy.
   Check that the tag does not already exist locally or remotely; never move an
   existing release tag. Publishing a tag can trigger deployment and needs approval.
6. Merge the release branch back into `develop` so stabilization fixes survive.
   Resolve conflicts deliberately and rerun affected checks on the integrated result.
7. Verify both destinations and the tag before authorized branch cleanup. Report
   deployment separately; a local merge or tag does not prove production deployment.

### Hotfix

1. Confirm the production defect and baseline. Branch from production, not
   `develop`, to avoid shipping unreleased features with the repair.
2. Make the smallest repair, add a regression check, and update patch-version
   metadata where required. Validate against the production code path.
3. Integrate into `main`, validate the result, and tag the patched production
   commit according to release policy.
4. With no active release, merge the hotfix into `develop` and test the result.
5. With an active release, integrate the hotfix into that release branch instead
   of relying only on `develop`. Its eventual release back-merge carries the repair
   into `develop`. If development needs the fix immediately, also integrate it
   there deliberately and track both paths. If the release is abandoned, explicitly
   propagate the repair to `develop`; do not lose it with the release branch.
6. Verify all required destinations before authorized cleanup. Record any deferred
   propagation with a concrete destination and follow-up, not simply "hotfix done."

## Integration and Safety Gates

- A request to explain or plan a workflow is not permission to mutate Git history.
  Commit, merge, tag, publish, deploy, and delete only within the user's authorized
  scope. A request to implement a fix alone is not permission to release it.
- Respect protected branches and required review. Prefer the repository's PR process
  over local merges into protected branches; do not bypass failed checks or hooks.
- For classic Gitflow merge-commit history, use `--no-ff` when policy calls for it.
  Do not override an established squash/rebase policy silently. Those policies
  change how integration must be verified and can complicate release back-merges.
- Inspect conflicts file by file. Never resolve an entire release merge by blindly
  choosing one side. Recheck version files, changelogs, and behavior after resolution.
- Do not force-push, rebase shared history, force-delete branches, or move published
  tags as routine cleanup. Use `git branch -d` only after confirming all required
  integrations; if it refuses, inspect why instead of escalating to `-D`.
- For ordinary merges, `git merge-base --is-ancestor <source-tip> <destination>`
  verifies reachability (exit status zero), not behavioral correctness. After a
  squash or cherry-pick, use PR records and resulting diffs/tests because source
  ancestry alone cannot prove integration.
- Push only approved, explicit branch/tag refs. Avoid broad `--all` or `--tags`
  pushes that could publish unrelated work. Keep local, remote, and deployed
  status distinct, especially if only part of a multi-destination release succeeds.

## Deliverable

Report the chosen lifecycle, verified base commit, branch names, required merge
destinations, checks actually run, and remaining approvals. For completed operations,
include resulting commit/tag identifiers, local versus published status, and any
outstanding back-merge or cleanup. Never claim a release is complete while a required
propagation path is missing.

## Source

Based on [Atlassian's Gitflow Workflow tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow),
accessed 2026-09-08. Adapted into operational instructions rather than reproduced.
The safety gates and explicit verification steps supplement the article's simplified
command examples; retain its modern-usage warning and active-release hotfix exception.
