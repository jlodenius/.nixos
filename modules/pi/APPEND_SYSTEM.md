# Environment
NixOS.

# Context
Avoid `/nix/store` reads unless necessary. Use `rg`/`find` first.
Read only small targeted ranges. Skip sourcemaps, generated files, vendored deps, and `node_modules`.

# Comments
Default to writing NO comments. Never comment self-explanatory code.
Only comment non-obvious rationale, workarounds, or subtle constraints.
