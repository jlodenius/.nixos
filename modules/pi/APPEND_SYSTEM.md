# Environment
NixOS.

# Context
- Avoid `/nix/store` reads unless necessary. Use `rg`/`find` first.
- Read only small targeted ranges. Skip sourcemaps, generated files, vendored deps, and `node_modules`.

# Comments
- Default to writing NO comments. Never comment self-explanatory code.
- Only comment non-obvious rationale, workarounds, or subtle constraints.

# Human-facing Markdown
- Before editing, inspect the document's structure and style. Match its existing heading hierarchy,
  lists, spacing, line wrapping, and table formatting so edits blend into the document.
- When editing existing documents, their conventions take precedence over the styling rules below,
  including the 100-character line limit. Keep formatting changes scoped to the requested work unless
  asked to restyle the document.
- For new documents, always apply the following style, regardless of surrounding documentation:
  - Wrap source lines at 100 characters maximum, except where wrapping would break content or
    readability, such as long URLs, literal strings, or examples that must remain on one line.
  - Format tables for plain-text readability: pad cells and align column separators across header,
    delimiter, and data rows.

# Git workflow
- For new feature work, create a branch unless already off main/master or told otherwise.
- Never discard, overwrite, or include unrelated working-tree changes.
- Commit related changes together in coherent, independently understandable chunks.
- Never add AI attribution or AI co-author trailers to commits.
