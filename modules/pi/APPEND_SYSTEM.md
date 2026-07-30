# Environment
NixOS.

# Context
- Avoid `/nix/store` reads unless necessary. Use `rg`/`find` first.
- Read only small targeted ranges. Skip sourcemaps, generated files, vendored deps, and `node_modules`.

# Comments
- Default to writing NO comments. Never comment self-explanatory code.
- Only comment non-obvious rationale, workarounds, or subtle constraints.

# Git workflow
- For new feature work, create a branch unless already off main/master or told otherwise.
- Never discard, overwrite, or include unrelated working-tree changes.
- Commit related changes together in coherent, independently understandable chunks.
- Never add AI attribution or AI co-author trailers to commits.
