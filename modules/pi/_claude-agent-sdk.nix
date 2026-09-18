{
  lib,
  buildNpmPackage,
  claude-code,
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

  # Match SDK 0.3.257 without changing the user's standalone Claude Code package.
  passthru.claudeCode = claude-code.override {
    manifest = {
      version = "2.1.257";
      platforms = {
        linux-x64.checksum = "9a64bda9d8722a1fa05bef9a5961d07e0331b99597eda9e2f6a732f3a0ff7f05";
        linux-arm64.checksum = "22f7d48f17193952c3c2d0b8bf2f31db2cd08fd5fb09a374fa321496b711d017";
      };
    };
  };

  meta = {
    description = "Claude Agent SDK provider for Pi";
    homepage = "https://github.com/pi-pod/pi-claude-agent-sdk";
    license = lib.licenses.mit;
  };
}
