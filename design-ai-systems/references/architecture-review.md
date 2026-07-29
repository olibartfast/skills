# AI Architecture Review Rubric

Use only the sections relevant to the system. Record evidence and status for each material item;
do not turn every question into a mandatory feature.

Source basis: [The AI Architect Mindset](https://gist.github.com/olibartfast/7eb377ed9e5adfa0a19011d55ea95053),
adapted into an operational review rubric.

## Contents

- Outcome and requirements
- End-to-end system
- Data
- Model lifecycle
- Compute and inference
- Scale, reliability, and observability
- Security and governance
- Economics and platform fit
- Evolution and decisions
- Finding format

## Outcome and requirements

- Is the business problem stated independently of a model or vendor?
- Are the owner, users, workflow, baseline, target, and deadline clear?
- Are model errors connected to business consequences?
- Are quality, latency, throughput, availability, privacy, safety, and cost targets measurable?
- Are hard constraints distinguished from preferences and assumptions?

## End-to-end system

- Does the design cover preprocessing, model execution, postprocessing, business rules, user
  experience, and feedback?
- Are interfaces, owners, state, and failure semantics explicit at each boundary?
- Is business logic kept outside the model where deterministic behavior is required?
- Are synchronous and asynchronous paths chosen from user and workload needs?
- Are external dependencies and deployment boundaries visible?

## Data

- Are origin, ownership, permitted use, provenance, and lineage known?
- Are schemas, validation, deduplication, labeling, and quality thresholds versioned?
- Are access, encryption, residency, retention, deletion, and audit requirements implemented?
- Are train, validation, and test sets protected from leakage?
- Are training and serving transformations consistent?
- Are drift and feedback monitored without converting model mistakes into new ground truth?

## Model lifecycle

- Is there a stable input/output contract independent of a specific model?
- Are artifacts immutable, versioned, traceable, scanned, and reproducible?
- Do evaluation sets represent production conditions and important subgroups?
- Are release gates tied to business and system metrics?
- Can models be compared, shadowed, canaried, rolled back, and replaced?
- Is fallback behavior safe when the model is unavailable or uncertain?

## Compute and inference

- Is placement—device, edge, on-premises, cloud, or hybrid—supported by constraints?
- Are CPU, GPU, NPU, VPU, precision, memory, and accelerator choices benchmarked?
- Are cold start, loading, warm-up, batching, caching, scheduling, and routing addressed?
- Are concurrency, queueing, backpressure, timeouts, and cancellation bounded?
- Are autoscaling signals aligned with the actual bottleneck?
- Is resource isolation sufficient for multiple models or tenants?

## Scale, reliability, and observability

- Are normal, peak, burst, and growth loads quantified?
- Are latency percentiles, throughput, saturation, queue depth, failures, quality, and drift
  observable?
- Are service-level objectives tied to alerts, owners, and runbooks?
- Are invalid input, dependency, runtime, memory, accelerator, network, region, and downstream
  failures covered?
- Does each critical failure have detection, containment, degradation, recovery, and a recovery
  test?
- Are backups, disaster recovery, and regional needs proportionate to business impact?

## Security and governance

- Are sensitive assets, trust boundaries, threats, and abuse cases identified?
- Are least privilege, secrets, encryption, tenant isolation, and audit trails in place?
- Are prompt, retrieval, model, dependency, and artifact supply chains controlled where relevant?
- Is it clear who approves data use, model releases, deployments, exceptions, and rollback?
- Are high-impact actions gated by deterministic controls or human review?
- Can the organization reproduce which data, code, configuration, and model produced a decision?

## Economics and platform fit

- Does the cost model include compute, utilization, idle capacity, storage, transfer,
  observability, evaluation, human review, and operations?
- Are cost per request, task, customer, or business outcome visible?
- Has the design been tested against normal, peak, and growth scenarios?
- Is added platform complexity justified by credible reuse?
- Are build-versus-buy and vendor lock-in considered with an exit path?

## Evolution and decisions

- Can components and models change without coordinated system-wide replacement?
- Are schemas, APIs, artifacts, and configurations compatible and versioned?
- Do migrations include staged rollout, rollback, deprecation, and ownership?
- Does the roadmap produce verified value in each phase?
- Are major tradeoffs recorded with options, rationale, consequences, and revisit signals?
- Is every open risk assigned an owner or decision deadline?

## Finding format

Use this compact structure:

```text
[severity] Finding title
Evidence: observed artifact, metric, or explicit absence
Impact: business or system consequence
Recommendation: smallest effective change
Validation: evidence that will demonstrate closure
Owner/phase: responsible role and delivery stage, when known
```

Use **critical** for an imminent safety, security, compliance, or business-continuity risk;
**high** for likely failure of a hard requirement; **medium** for a material operability or
evolution risk; and **low** for bounded improvement. Do not inflate severity because a preferred
technology or pattern is absent.
