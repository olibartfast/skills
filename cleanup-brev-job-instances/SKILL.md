---
name: cleanup-brev-job-instances
description: Delete NVIDIA Brev cloud instances after their assigned jobs complete to avoid ongoing compute costs. Use when finishing a Brev training, inference, benchmark, or batch job, or when asked to clean up its instance after completion.
---

# Clean Up Brev Job Instances

Make instance deletion the final step of a completed Brev job. Preserve required
results first, then delete the exact instance assigned to that job and verify
removal. Stopping an instance does not fulfill a request to destroy it.

## Establish the Cleanup Contract

- Identify the job, Brev organization, and exact instance name and ID from the
  current task and `brev ls --json`. Record the identity before running the job
  when possible. Do not select instances by a loose name match or idle GPU alone.
- An explicit instruction to delete the job's instance after completion authorizes
  that scoped deletion once its conditions are met. Do not ask for the same
  permission again. Merely creating this skill or requesting compute work does
  not authorize deleting an existing instance.
- Honor explicit retention instructions and shared-instance ownership. If the
  instance serves other jobs or users, do not delete it as part of one job's
  cleanup without authorization covering those workloads.
- Brev Connect nodes listed by `brev ls nodes` are a separate namespace whose
  lifecycle Brev does not manage. Do not treat a disconnected node as a deletable
  cloud instance.

## Verify Completion and Preserve Results

Use the job's exit status, scheduler state, or equivalent authoritative completion
record. An SSH disconnect, quiet logs, or low GPU utilization does not establish
completion. Check for child processes, queued stages, uploads, or other workloads
that still need the instance.

Copy required outputs, checkpoints, logs, and reproducibility details to the
user's intended durable destination. Use `brev copy` or the existing artifact
upload path, then verify the destination artifacts with appropriate existence,
size, checksum, or readability checks. A path on the instance is not a durable
backup for this purpose. Do not delete while required outputs exist only there
or transfers remain incomplete. Avoid copying credentials or unrelated data.

For failed or canceled jobs, retain useful diagnostics and follow the user's
failure-cleanup policy. Do not infer permission to delete a failed job's instance
from an instruction that applies only to successful completion.

## Delete and Verify

1. Re-list instances in the intended organization immediately before deletion.
   Confirm the name still maps to the recorded ID and that completion, artifact,
   and ownership conditions still hold. If the name now identifies a different
   instance, stop and resolve the mismatch.
2. Run `brev delete <exact-instance-name>` for that single verified instance.
   Check `brev delete --help` for the installed CLI's supported selectors or
   confirmation options when needed; do not invent flags. If a stable ID selector
   is supported, prefer it. Respect execution permissions and confirmation prompts
   within the existing deletion authorization.
3. Recheck `brev ls --json` in the same organization until the recorded instance
   is absent or deletion reaches a documented terminal state. Use bounded polling
   and report pending deletion if it has not completed. A command returning
   successfully or SSH becoming unreachable does not alone prove removal.
4. Treat an already absent instance as completed cleanup only after a successful
   listing in the correct organization. Authentication and network failures are
   not evidence of absence. Before retrying a failed delete, recheck identity
   and state; do not repeatedly delete by a potentially reused name.

Never use bulk deletion pipelines, delete unrelated instances, or fall back to
stopping an instance and claim destruction succeeded. If deletion is blocked,
report the exact remaining instance, error, and next action promptly so ongoing
cost is visible. Do not claim all billing has ceased: separate disks, snapshots,
or other resources may have their own lifecycle; remove those only within scope.

## Report

State the job's completion evidence, where verified results were saved, the
instance name/ID and organization, and whether deletion was verified or remains
pending. If execution ends before the job completes, state that cleanup remains
outstanding; do not imply a background cleanup mechanism was installed unless
one was actually configured and verified within the user's request.
