---
name: cleanup-merged-git-branches
description: Delete Git branches locally and on their remote after verifying they have merged into develop. Use for post-merge cleanup or requests to remove branches already integrated into develop.
---

# Clean Up Merged Git Branches

When a scoped branch has merged into `develop`, remove its local and remote
branch refs after verification. A request to clean up merged branches authorizes
both deletions; respect execution permissions without asking again unnecessarily.
Creating this skill or discussing cleanup does not authorize deleting live branches.

## Establish Scope and Verify Integration

- Read repository instructions and inspect `git status --short --branch`,
  `git branch -avv`, `git remote -v`, and `git worktree list --porcelain`.
- Use the named branch or the branch just merged in the current task. Enumerate
  all eligible branches only when the user requests bulk cleanup.
- Resolve the correct remote and remote branch name from the upstream or PR.
  Do not assume `origin`, identical local/remote names, or that an upstream of
  `develop` is the feature branch to delete.
- Never delete `develop`, the remote default branch, production branches such as
  `main` and `master`, or protected/long-lived branches. Release and hotfix branches
  must also satisfy every required integration destination in repository policy.
- Fetch the selected remote with pruning and confirm its `develop` ref exists.
  Use the freshly fetched remote `develop` as the integration destination;
  a merge into local-only `develop` is insufficient for remote deletion.
- Record the exact local and remote candidate commit IDs. For ordinary merges,
  verify **each existing tip independently** with
  `git merge-base --is-ancestor <candidate-oid> <remote-develop-ref>`.
  A merged remote tip does not prove that additional local commits are merged.
- For squash/rebase merges, ancestry may fail. Require authoritative merged-PR
  evidence targeting `develop`, confirm the PR's final source tip matches the
  candidate, and check for subsequent local or remote commits. A closed PR or
  similar diff alone is insufficient. If integration cannot be established, skip
  the branch and explain the missing evidence.

## Delete Verified Refs

Preserve uncommitted work. If the candidate is checked out in this worktree,
switch to an existing safe branch such as `develop` only with a clean worktree
and no operation in progress. Do not stash, reset, or discard changes. If another
worktree has the branch checked out, skip local deletion and report that worktree.

Recheck the refs before acting. Delete the remote ref using the verified remote
OID as a lease so concurrent new commits cannot be deleted. With `remote`,
`remote_branch`, and `verified_remote_oid` resolved from the checks above:

```bash
git push --force-with-lease="refs/heads/${remote_branch}:${verified_remote_oid}" \
  "$remote" ":refs/heads/${remote_branch}"
```

This lease guards only the explicit branch deletion. Never replace it with an
unconditional force push. If the lease fails, refetch and reassess; do not retry
blindly. Treat an already absent remote branch as completed remote cleanup.

For the local branch, confirm its tip still matches the verified local OID, then
use `git branch -d -- "$local_branch"`. The explicit merge check above remains
required because `-d` can use the branch's upstream rather than `develop`.
If `-d` refuses, report why; do not automatically escalate to `-D`, including
after squash/rebase merges. Force deletion requires explicit authorization for
that verified branch. Honor server branch protections and report denied deletion.

## Confirm and Report

Verify local absence with `git show-ref --verify refs/heads/<local-branch>` and
remote absence with `git ls-remote --heads <remote> refs/heads/<remote-branch>`;
distinguish an empty successful result from a network or authentication failure.
Prune stale tracking refs after successful remote deletion.

Report which branches were removed locally and remotely, the `develop` commit
used as evidence, and any skipped branches or partial failures. Do not claim both
deletions succeeded when only one did.
