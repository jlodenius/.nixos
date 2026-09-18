{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
}:
buildNpmPackage {
  pname = "pi-claude-agent-sdk";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "pi-pod";
    repo = "pi-claude-agent-sdk";
    rev = "5293c03fc1e250725c9e23472eec767a5a302caf";
    hash = "sha256-k09zL03uJGgRzpCCCEXjBJHidLspq5k63IEfjinBMxs=";
  };

  # Pi supplies its own packages; Claude Code comes from Nix, not SDK binaries.
  postPatch = ''
    ${jq}/bin/jq 'del(.devDependencies, .peerDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    ${jq}/bin/jq '
      del(.packages[""].devDependencies, .packages[""].peerDependencies,
          .packages["node_modules/@anthropic-ai/claude-agent-sdk"].optionalDependencies)
      | .packages |= with_entries(select(.value.dev != true and .value.optional != true))
    ' package-lock.json > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json
  '';

  npmDepsHash = "sha256-6ihsB0f4qHXpjPwlmyh8xj5O7RGTHk2RScFzObcQEH8=";
  npmFlags = ["--ignore-scripts" "--omit=dev" "--omit=optional"];
  dontNpmBuild = true;

  meta = {
    description = "Claude Agent SDK provider for Pi";
    homepage = "https://github.com/pi-pod/pi-claude-agent-sdk";
    license = lib.licenses.mit;
  };
}
