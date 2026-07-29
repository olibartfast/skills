# CPU Optimization KB Schema and Checks

## Contents

- Source-of-truth model
- Collection schemas
- Search behavior
- MCP compatibility
- Validation

## Source-of-truth model

The source project stores the catalog in a Python `LEARNING_RESOURCES` dictionary. Server tools
filter or return this static data. Inspect the actual handlers before changing fields because a
schema can look valid while silently becoming undiscoverable.

Do not introduce network fetching, a database, embeddings, or generated cache files as part of a
routine catalog edit.

## Collection schemas

Match the existing collection. Typical shapes are:

### Books

```python
{
    "id": "stable-kebab-id",
    "title": "Resource title",
    "author": "Author name",
    "url": "https://...",
    "level": "beginner|intermediate|advanced",
    "topics": ["specific topic", "search synonym"],
    "description": "Keyword-rich factual description",
}
```

### Online resources and projects

These may omit `author` or `level` in the existing source. Preserve local consistency and only add
fields if handlers and documentation intentionally adopt them.

### Labs

```python
{
    "id": "lab-02",
    "title": "Branch Prediction",
    "duration": "1-2 hours",
    "topics": ["branch prediction", "branchless programming"],
    "description": "What the learner practices",
    "level": "beginner",
    "speedupTargets": {
        "basic": "2x",
        "good": "5x",
        "excellent": "10x+",
    },
}
```

If the catalog tracks planned labs, preserve status explicitly or ensure adjacent documentation
makes the distinction. A catalog entry is not proof of an implementation.

### Platform tools

Tool entries sit under platform keys such as `linux`, `windows`, and `macos`. Include `name`,
`description`, and `usage` when the tool has a concise command-line invocation.

## Search behavior

The original server uses case-insensitive substring matching rather than semantic retrieval.
Therefore:

- include exact terms users will search for
- add common variants such as `simd`, `vectorization`, and `intrinsics`
- avoid keyword stuffing unrelated concepts
- keep topics as strings
- use a concrete description, not promotional wording

Test a resource by title, one topic, one synonym in its description, and a no-match query.

## MCP compatibility

- Keep tool outputs JSON-serializable: dictionaries, lists, strings, numbers, booleans, and null.
- Preserve tool argument names and documented resource URIs.
- Use full Python type hints if that is the server convention.
- Remember built-in generics such as `dict[str, object]` require Python 3.9+.
- Update README and examples when exposing a new tool or changing configuration.
- Keep filesystem paths configurable; do not copy hardcoded workspace paths.

## Validation

Run syntax compilation without polluting the global environment:

```bash
python3 -m py_compile mcp-server/knowledge_base.py mcp-server/server.py
```

Then check:

1. every ID is unique across the intended scope
2. required keys exist for each collection
3. `json.dumps(LEARNING_RESOURCES)` succeeds
4. search is case-insensitive
5. representative tool calls return the new or changed item
6. unknown IDs and empty results remain well-formed
7. documented tool list and resource URIs match the server

If dependencies are needed, create a project virtual environment and install the declared
requirements there.
