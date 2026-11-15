{
  lib,
  pi-coding-agent,
  fetchFromGitHub,
  fetchurl,
  fetchNpmDeps,
}:
pi-coding-agent.overrideAttrs (final: old: {
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v1.5.2";
    hash = "sha256-0dKtABQqfvCLF0WOydu5rpycMqC+N8Pc9Ex4BWKElyw=";
  };

  npmDepsHash = "sha256-uHehffbEB2uU9U9uSpfWojzxvQyqeicbh/esCwk4neQ=";
  npmDeps = fetchNpmDeps {
    name = "pi-coding-agent-${final.version}-npm-deps";
    inherit (final) src;
    hash = final.npmDepsHash;
  };

  modelData = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-1.5.2.tgz";
    hash = "sha256-1XFe+oNMI7/fEKBCtJ307hacyZAAvxbXmY+rLVM7Rfg=";
  };

  # Pi 1.5 adds a runtime workspace absent from the pinned nixpkgs install list.
  postInstall =
    (
      if lib.hasInfix "@earendil-works/pi-schema:" old.postInstall
      then old.postInstall
      else
        assert lib.hasInfix "@earendil-works/pi-mcp:packages/mcp" old.postInstall;
          lib.replaceStrings
          ["@earendil-works/pi-mcp:packages/mcp"]
          ["@earendil-works/pi-schema:packages/schema @earendil-works/pi-mcp:packages/mcp"]
          old.postInstall
    )
    + ''
      find "$nm" -type l -lname '*/apps/*' -delete
    '';
})
