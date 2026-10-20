{
  lib,
  buildNpmPackage,
  importNpmLock,
  writeText,
  src,
}: let
  # Pi supplies its own packages; Claude Code comes from Nix, not SDK binaries.
  removeDevDeps = package: builtins.removeAttrs package ["devDependencies" "peerDependencies"];
  package = removeDevDeps (lib.importJSON "${src}/package.json");
  upstreamLock = lib.importJSON "${src}/package-lock.json";
  packageLock =
    upstreamLock
    // {
      packages =
        lib.filterAttrs (_: dependency: !(dependency.dev or false) && !(dependency.optional or false)) upstreamLock.packages
        // {
          "" = removeDevDeps upstreamLock.packages."";
          "node_modules/@anthropic-ai/claude-agent-sdk" = builtins.removeAttrs upstreamLock.packages."node_modules/@anthropic-ai/claude-agent-sdk" ["optionalDependencies"];
        };
    };
in
  buildNpmPackage {
    pname = package.name;
    inherit (package) version;
    inherit src;

    postPatch = ''
      cp ${writeText "package.json" (builtins.toJSON package)} package.json
      cp ${writeText "package-lock.json" (builtins.toJSON packageLock)} package-lock.json
    '';

    npmDeps = importNpmLock {inherit package packageLock;};
    npmConfigHook = importNpmLock.npmConfigHook;
    npmFlags = ["--ignore-scripts" "--omit=dev" "--omit=optional"];
    dontNpmBuild = true;

    meta = {
      description = "Claude Agent SDK provider for Pi";
      homepage = "https://github.com/pi-pod/pi-claude-agent-sdk";
      license = lib.licenses.mit;
    };
  }
