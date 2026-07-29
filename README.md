# Agent Skills

Portable agent skills derived from practical engineering repositories and technical guides. Each
package contains a `SKILL.md` and can be installed independently in compatible coding agents.

## Skill Catalog

### CPU Optimization

| Skill | Purpose |
| --- | --- |
| [`diagnose-cpu-performance`](skills/diagnose-cpu-performance/) | Classify CPU bottlenecks from source, benchmarks, compiler output, and hardware counters |
| [`review-cpp-simd`](skills/review-cpp-simd/) | Review C++ kernels for auto-vectorization and portable SIMD readiness |
| [`author-cpu-optimization-lab`](skills/author-cpu-optimization-lab/) | Create deterministic, benchmark-driven C++17 optimization labs |
| [`edit-cpu-optimization-kb`](skills/edit-cpu-optimization-kb/) | Maintain a static CPU optimization learning catalog and MCP assistant |

### CUDA Parallel Programming

| Skill | Purpose |
| --- | --- |
| [`select-cuda-parallel-patterns`](select-cuda-parallel-patterns/) | Select and compose CUDA patterns for a GPU workload |
| [`implement-cuda-data-primitives`](implement-cuda-data-primitives/) | Implement reductions, scans, maps, gathers, scatters, and histograms |
| [`optimize-cuda-memory-locality`](optimize-cuda-memory-locality/) | Design tiled and stencil kernels around reuse and memory locality |
| [`coordinate-cuda-thread-groups`](coordinate-cuda-thread-groups/) | Use warp primitives and Cooperative Groups safely |
| [`pipeline-cuda-streams`](pipeline-cuda-streams/) | Overlap transfers and computation with asynchronous stream pipelines |
| [`profile-optimize-cuda`](profile-optimize-cuda/) | Diagnose CUDA bottlenecks with NVIDIA profiling tools |

## Install

Install from this repository with a compatible skills client, or copy one complete skill
directory into the skills directory recognized by your agent:

```bash
# Skill stored under skills/
cp -r skills/diagnose-cpu-performance ~/.codex/skills/

# Top-level skill
cp -r select-cuda-parallel-patterns ~/.codex/skills/
```

Keep the complete package together, including `SKILL.md`, `agents/`, and any `references/`,
`scripts/`, or `assets/` directories.

## Sources

The CPU optimization collection is based on
[`olibartfast/cpu-optimizations-lab`](https://github.com/olibartfast/cpu-optimizations-lab),
including its branch-prediction benchmark, performance rules, lab-authoring conventions, and
static MCP learning assistant.

The CUDA collection is based on
[Parallel Programming Pattern Fundamentals in CUDA](https://olibartfast.ninja/blog/cuda-parallel-programming-patterns.html)
and reconciled with current NVIDIA CUDA, CCCL, and Nsight documentation.

Additional structural references:

- <https://github.com/nvidia/skills>
- <https://github.com/NVIDIA-AI-IOT/jetson-device-skills>
- <https://github.com/NVIDIA-AI-IOT/DeepStream_Coding_Agent>
