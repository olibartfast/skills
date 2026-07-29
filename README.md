# Agent Skills

Portable agent skills derived from practical engineering repositories and technical guides. Each
package contains a `SKILL.md` and can be installed independently in compatible coding agents.

## Install with `npx`

Install every skill in this repository for every agent supported by the
[`skills`](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills@latest add olibartfast/skills --all
```

List the available skills without installing them:

```bash
npx skills@latest add olibartfast/skills --list
```

Install one skill for all supported agents:

```bash
npx skills@latest add olibartfast/skills \
  --skill profile-optimize-cuda \
  --agent '*' \
  --yes
```

Install all skills for a specific agent:

```bash
npx skills@latest add olibartfast/skills \
  --skill '*' \
  --agent codex \
  --yes
```

Project installation is the default. Add `--global` to make the selected skills available to the
selected agents across all projects.

### Install by topic

Use the bundled scripts to install one complete topic for agents detected by the `skills` CLI:

```bash
./scripts/install-meta-horizon-skills.sh
./scripts/install-cpu-optimization-skills.sh
./scripts/install-cpp-architecture-skills.sh
./scripts/install-cuda-parallel-programming-skills.sh
```

The scripts install non-interactively into the current project without hardcoding an agent.
Pass additional supported `skills add` options after the script name; for example:

```bash
./scripts/install-cuda-parallel-programming-skills.sh --global
./scripts/install-cuda-parallel-programming-skills.sh --agent codex
./scripts/install-cuda-parallel-programming-skills.sh --agent '*'
```

## Skill Catalog

### Meta Horizon OS and Meta Quest

| Skill | Purpose |
| --- | --- |
| [`research-meta-horizon-docs`](research-meta-horizon-docs/) | Find current official documentation and API guidance across Horizon build paths |
| [`build-meta-quest-unity`](build-meta-quest-unity/) | Build, debug, and optimize Meta Quest applications in Unity |
| [`build-meta-quest-unreal`](build-meta-quest-unreal/) | Build, debug, and optimize Meta Quest applications in Unreal Engine |
| [`build-meta-spatial-sdk-apps`](build-meta-spatial-sdk-apps/) | Build spatial and hybrid Android applications with Meta Spatial SDK |
| [`adapt-android-apps-horizon`](adapt-android-apps-horizon/) | Adapt conventional Android applications for Meta Horizon OS |
| [`build-meta-quest-native`](build-meta-quest-native/) | Build native C/C++ Meta Quest applications with OpenXR |
| [`build-meta-quest-webxr`](build-meta-quest-webxr/) | Build immersive web experiences for Meta Quest Browser |

### CPU Optimization

| Skill | Purpose |
| --- | --- |
| [`diagnose-cpu-performance`](diagnose-cpu-performance/) | Classify CPU bottlenecks from source, benchmarks, compiler output, and hardware counters |
| [`review-cpp-simd`](review-cpp-simd/) | Review C++ kernels for auto-vectorization and portable SIMD readiness |
| [`author-cpu-optimization-lab`](author-cpu-optimization-lab/) | Create deterministic, benchmark-driven C++17 optimization labs |
| [`edit-cpu-optimization-kb`](edit-cpu-optimization-kb/) | Maintain a static CPU optimization learning catalog and MCP assistant |

### C++ Architecture and Design

| Skill | Purpose |
| --- | --- |
| [`modernize-cpp-design`](modernize-cpp-design/) | Select modern C++ design mechanisms and simplify legacy pattern implementations |
| [`modernize-cpp-boundaries`](modernize-cpp-boundaries/) | Isolate legacy code and external APIs behind safe modern C++ boundaries |
| [`compose-cpp-components`](compose-cpp-components/) | Build explicit dependency graphs, composition roots, factories, and plugin registries |
| [`engineer-cpp-dataflows`](engineer-cpp-dataflows/) | Design bounded, low-latency C++ pipelines with explicit ownership and backpressure |
| [`model-cpp-domain-services`](model-cpp-domain-services/) | Separate domain logic from persistence, transport, and deployment concerns |
| [`harden-cpp-services`](harden-cpp-services/) | Add deadlines, bounded retries, circuit breakers, bulkheads, and graceful degradation |

### CUDA Parallel Programming

| Skill | Purpose |
| --- | --- |
| [`select-cuda-parallel-patterns`](select-cuda-parallel-patterns/) | Select and compose CUDA patterns for a GPU workload |
| [`implement-cuda-data-primitives`](implement-cuda-data-primitives/) | Implement reductions, scans, maps, gathers, scatters, and histograms |
| [`optimize-cuda-memory-locality`](optimize-cuda-memory-locality/) | Design tiled and stencil kernels around reuse and memory locality |
| [`coordinate-cuda-thread-groups`](coordinate-cuda-thread-groups/) | Use warp primitives and Cooperative Groups safely |
| [`pipeline-cuda-streams`](pipeline-cuda-streams/) | Overlap transfers and computation with asynchronous stream pipelines |
| [`profile-optimize-cuda`](profile-optimize-cuda/) | Diagnose CUDA bottlenecks with NVIDIA profiling tools |

## Manual installation

If `npx` is unavailable, copy one complete skill directory into the skills directory recognized
by your agent:

```bash
cp -r diagnose-cpu-performance ~/.codex/skills/
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

The Meta Horizon collection is based on Meta's
[LLM resources for AI](https://developers.meta.com/horizon/essentials/ai-solutions/) and routes
agents to the current LLM-optimized documentation and API indexes for each supported build path.

Additional structural references:

- <https://github.com/nvidia/skills>
- <https://github.com/NVIDIA-AI-IOT/jetson-device-skills>
- <https://github.com/NVIDIA-AI-IOT/DeepStream_Coding_Agent>
