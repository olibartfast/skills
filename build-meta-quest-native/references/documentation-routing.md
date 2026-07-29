# Native and OpenXR Documentation Routing

Start with:

- Documentation index: <https://developers.meta.com/horizon/llmstxt/documentation/native/llms.txt/>

Search for the requested OpenXR feature and its Android, graphics, lifecycle, input, extension,
rendering, debugging, testing, and optimization guidance. Native entries may contain additional
path segments such as `android/`; always use the exact page URL from the index.

Also consult when relevant:

- Khronos OpenXR registry: <https://registry.khronos.org/OpenXR/>
- Design: <https://developers.meta.com/horizon/llmstxt/design/llms.txt/>
- Policies: <https://developers.meta.com/horizon/llmstxt/policy/llms.txt/>
- Distribution: <https://developers.meta.com/horizon/llmstxt/resources/llms.txt/>

Reconcile documentation with the repository's OpenXR headers, loader, NDK, Android API level,
enabled extensions, and runtime logs. Exclude deprecated native SDK guidance unless the codebase
still depends on it.
