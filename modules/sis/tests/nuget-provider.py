import http.server
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading


def require(condition, message):
    if not condition:
        raise AssertionError(message)


class UnauthorizedFeed(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(401)
        self.send_header("WWW-Authenticate", 'Basic realm="local-plugin-test"')
        self.end_headers()

    def log_message(self, *_):
        pass


def verify(dotnet, provider):
    with tempfile.TemporaryDirectory(prefix="nuget-provider-test-") as directory:
        root = Path(directory)
        tools = root / ".dotnet/tools"
        tools.mkdir(parents=True)
        log = root / "provider.log"
        marker = root / "stale-launcher-started"
        stale = tools / "nuget-plugin-microsoft-artifacts-credential-provider"
        stale.write_text(f'#!/bin/sh\n: > "{marker}"\nexit 1\n')
        stale.chmod(0o755)
        env = {
            "HOME": str(root),
            "TERM": "xterm",
            "PATH": f"{tools}:{Path(dotnet).parent}:{os.defpath}",
            "DOTNET_CLI_TELEMETRY_OPTOUT": "1",
            "DOTNET_SKIP_FIRST_TIME_EXPERIENCE": "1",
            "DOTNET_GENERATE_ASPNET_CERTIFICATE": "false",
            "ARTIFACTS_CREDENTIALPROVIDER_LOG_PATH": str(log),
        }
        help_result = subprocess.run(
            [dotnet, provider, "-h"], env=env, text=True, capture_output=True, timeout=20
        )
        require(help_result.returncode == 0, help_result.stdout + help_result.stderr)
        require("Azure Artifacts" in help_result.stdout, "Provider help missing")
        log.unlink(missing_ok=True)
        (root / "Probe.csproj").write_text(
            '<Project Sdk="Microsoft.NET.Sdk">'
            '<PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>'
            '<ItemGroup><PackageReference Include="Nix.CredentialProvider.Probe" '
            'Version="1.0.0" /></ItemGroup></Project>'
        )
        with http.server.ThreadingHTTPServer(("127.0.0.1", 0), UnauthorizedFeed) as server:
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            (root / "NuGet.Config").write_text(
                '<configuration><packageSources><clear />'
                f'<add key="probe" value="http://127.0.0.1:{server.server_port}/v3/index.json" '
                'allowInsecureConnections="true" />'
                '</packageSources></configuration>'
            )
            try:
                with (root / "restore.log").open("w") as output_file:
                    result = subprocess.run(
                        [
                            dotnet, "restore", "Probe.csproj", "--configfile", "NuGet.Config",
                            "--disable-build-servers",
                        ],
                        cwd=root,
                        env=env,
                        stdout=output_file,
                        stderr=subprocess.STDOUT,
                        timeout=30,
                    )
            finally:
                server.shutdown()
                thread.join()
        output = (root / "restore.log").read_text()
        require(not marker.exists(), "NuGet discovered the stale PATH launcher")
        require("GLIBC_" not in output, output)
        require("Pipe is broken" not in output, output)
        require("Problem starting the plugin" not in output, output)
        require(result.returncode != 0 and "401" in output, output)
        events = log.read_text() if log.exists() else ""
        require(provider in events, "NuGet did not discover the configured provider DLL")
        require(
            "Initialize" in events,
            f"NuGet plugin did not complete handshake and initialize:\n{output}\n{events}",
        )
        require(
            "GetAuthenticationCredentials" in events,
            f"NuGet did not request credentials from the provider:\n{output}\n{events}",
        )
        print("PASS: provider help, NuGet handshake/auth request, stale launcher excluded")
        print("The localhost restore intentionally fails with HTTP 401; no real feed is contacted.")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(f"Usage: {sys.argv[0]} DOTNET_EXECUTABLE PROVIDER_DLL")
    verify(*sys.argv[1:])
