---
name: research-meta-horizon-docs
description: Find and synthesize current official Meta Horizon OS documentation for Unity, Unreal, Spatial SDK, Android Apps, Native OpenXR, and WebXR. Use when answering Meta Quest development questions, locating SDK or API guidance, checking whether advice is current or deprecated, comparing build paths, or grounding another Horizon implementation skill in primary sources.
---

# Research Meta Horizon Documentation

Ground Horizon development advice in the smallest relevant set of current official pages.

## Workflow

1. Identify the build path, feature, installed SDK or engine version, target device, and task.
2. Read [references/official-indices.md](references/official-indices.md).
3. If Meta VR CLI documentation tools are available, use `search_doc` to discover candidates and
   `fetch_meta_quest_doc` to retrieve each selected page.
4. Otherwise, open the build path's `llms.txt` index, select relevant Markdown pages, and fetch
   their full content directly.
5. Retrieve the API reference index when exact classes, methods, signatures, or version support
   matter.
6. Add shared design, policy, or distribution pages only when they affect the task.
7. Reconcile the documentation with the repository's installed versions and existing
   architecture.
8. Report the answer, version assumptions, deprecations, and direct source URLs.

## Research Rules

- Prefer official LLM-optimized Markdown over navigation pages or search snippets.
- Use index entries for discovery, not as proof of detailed behavior.
- Fetch only the pages needed to answer the question.
- Prefer `latest` for discovery, then verify compatibility with the installed version.
- Treat Spatial SDK API references as version-pinned unless Meta publishes a `latest` alias.
- Do not recommend deprecated or retired APIs for new work.
- Distinguish documented facts from implementation inferences.
- Re-check policies, submission rules, supported versions, and API signatures at task time.
- Never invent package names, manifest keys, permissions, extension support, or device behavior.

## Deliverable

Provide:

1. selected build path and version context;
2. concise answer or implementation guidance;
3. relevant official pages and API references;
4. deprecated or conflicting guidance excluded;
5. unresolved version or device-specific questions.
