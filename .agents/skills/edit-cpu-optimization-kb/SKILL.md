---
name: edit-cpu-optimization-kb
description: Maintain a static Python knowledge base and MCP learning assistant for CPU optimization resources, labs, profiling tools, and performance rules. Use when adding or correcting resource metadata, improving substring-search discoverability, extending learning paths, updating lab records, or verifying JSON-serializable MCP tool outputs.
---

# Edit the CPU Optimization Knowledge Base

Maintain the static catalog without schema drift or misleading curriculum status.

## Workflow

1. Inspect the server handlers and current knowledge-base structure before editing.
2. Identify the target collection: books, online resources, projects, labs, platform tools, or
   repository performance rules.
3. Verify factual metadata and URLs when current accuracy matters.
4. Choose a stable, unique lowercase kebab-case `id`.
5. Match the existing entry shape and ordering.
6. Write specific topics and a keyword-rich description for case-insensitive substring search.
7. Keep every returned value JSON-serializable.
8. Run syntax, duplicate-ID, search, and affected-tool smoke checks.

Read [references/kb-schema-and-checks.md](references/kb-schema-and-checks.md) before editing the
catalog or MCP handlers.

## Guardrails

- Edit the declared static source of truth; do not add external loading without an explicit
  architecture change.
- Do not invent authors, levels, URLs, benchmark claims, or implementation status.
- Preserve collection-specific schemas instead of forcing fields that the server does not use.
- Keep planned labs distinguishable from implemented labs.
- Update tool documentation when tool names, arguments, or resource URIs change.

## Output

Report:

1. entries or handlers changed
2. schema and discoverability decisions
3. factual verification performed
4. validation and smoke-test results
5. any remaining stale or ambiguous data
