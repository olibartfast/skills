---
description: "Design, review, or evolve production AI and machine-learning systems around measurable business outcomes. Use when Codex must turn an AI use case into an end-to-end architecture; compare model, compute, deployment, or platform options; assess an existing AI architecture; define data, inference, evaluation, observability, resilience, security, governance, cost, or scaling plans; or create a phased roadmap that keeps models replaceable."
---
# Design AI Systems

Design the ecosystem around the model. Treat the model as one replaceable component in a
larger business, data, compute, serving, operations, and governance system.

## Choose the task

- **New design:** Build an end-to-end architecture and staged delivery plan.
- **Architecture review:** Inspect supplied artifacts, preserve observed facts, identify gaps,
  and prioritize changes by risk and impact.
- **Decision analysis:** Compare named options against explicit workload and business criteria.
- **Evolution plan:** Move a current system toward a target state without assuming a rewrite.

Read [references/architecture-review.md](references/architecture-review.md) when performing a
formal review, when requirements are incomplete, or when a design needs a completeness pass.

## Follow the workflow

### 1. Frame the outcome

State the business problem before selecting a model or vendor. Capture:

- user or operational outcome;
- owner and affected users;
- current baseline and target metric;
- cost of false positives, false negatives, latency, and downtime;
- hard constraints such as privacy, residency, safety, budget, hardware, or deadline.

Ask only for information that would materially change the design. Otherwise, make conservative
assumptions and label them.

### 2. Define measurable requirements

Translate the outcome into testable targets. Include the applicable dimensions:

- quality and task-specific evaluation metrics;
- p50/p95/p99 latency and throughput;
- availability, recovery time, and recovery point;
- traffic shape, payload size, concurrency, and growth;
- data freshness, retention, and deletion;
- unit economics and total budget;
- auditability, explainability, and human-review requirements.

Separate hard constraints from preferences. Never invent precise targets without marking them as
assumptions or recommendations.

### 3. Map the whole system

Trace the path from source data to business action:

```text
Sources -> validation -> preparation -> model -> postprocessing
        -> business rules -> product or operator -> feedback
```

For every boundary, identify ownership, interface, state, trust level, failure behavior, and
observability. Include offline training or adaptation paths when relevant. Show a diagram only
when it makes dependencies or deployment boundaries clearer.

### 4. Design data as a product

Specify provenance, consent or lawful use, collection, schemas, validation, labeling, lineage,
versioning, access, retention, deletion, and quality monitoring. Prevent training-serving skew
and data leakage. Define how production feedback becomes evaluation or training data without
silently reinforcing errors.

### 5. Separate model concerns from serving concerns

Define a stable model contract: inputs, outputs, metadata, error behavior, resource envelope, and
compatibility policy. Then design:

- model registry and immutable versions;
- offline and online evaluation gates;
- packaging, loading, warm-up, routing, batching, and autoscaling;
- shadow, canary, A/B, or champion-challenger rollout;
- rollback and fallback behavior;
- support for model replacement or multiple models.

Choose CPU, GPU, NPU, VPU, accelerator, precision, and placement from measured workload needs.
Do not assume training hardware or the most accurate model is the right inference choice.

### 6. Make operation and failure explicit

Define telemetry for product outcomes, model quality, drift, latency, throughput, saturation,
queue depth, resource use, and failure rates. Assign alerts, owners, runbooks, and service-level
objectives.

Enumerate failures across inputs, data dependencies, model runtime, memory, accelerators,
networks, regions, and downstream business actions. For each material failure, specify detection,
containment, degraded behavior, recovery, and validation after recovery.

### 7. Address security and governance

Identify sensitive assets, trust boundaries, abuse cases, access controls, secrets, encryption,
isolation, supply-chain risks, and audit trails. Define who may approve data, models, deployments,
exceptions, and rollbacks. Add human oversight where automated errors have significant impact.

### 8. Quantify scale and economics

Build a transparent cost model from workload assumptions. At minimum, consider cost per request
or task, utilization, idle capacity, storage and transfer, observability, evaluation, human
review, and operational labor. Test normal, peak, and growth scenarios. Prefer the simplest
architecture that meets the stated targets.

### 9. Plan for evolution

Separate immediate needs from platform capabilities worth reusing. Stage work so each phase has
an independently verifiable outcome. Include migration, compatibility, deprecation, rollback,
and exit plans. Avoid speculative platform work unless multiple credible consumers justify it.

### 10. Record decisions and verify completeness

For every consequential choice, record:

- context and decision drivers;
- considered options;
- decision and rationale;
- consequences and risks;
- evidence needed to revisit it.

Run the review rubric before finalizing. Mark each relevant item as **addressed**, **assumed**,
**open**, or **not applicable**.

## Produce the deliverable

Adapt depth to the request, but default to:

1. Executive summary and recommendation
2. Outcomes, requirements, assumptions, and open questions
3. System context and component responsibilities
4. Data and model lifecycle
5. Inference and deployment design
6. Reliability, observability, security, and governance
7. Capacity and cost model
8. Tradeoff or decision table
9. Phased roadmap with acceptance criteria
10. Key risks and decision records

For reviews, distinguish evidence from inference and recommendation. Prioritize findings by
business impact and likelihood, cite the inspected artifact location, and avoid redesigning
parts that already satisfy the requirements.
