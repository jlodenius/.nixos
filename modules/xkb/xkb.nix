{...}: {
  flake.nixosModules.xkb = {pkgs, ...}: let
    buildWindowsLayout = cross: architecture:
      cross.stdenv.mkDerivation {
        pname = "kbdcustom-${architecture}";
        version = "1";
        src = ./windows;

        dontConfigure = true;

        buildPhase = ''
          runHook preBuild
          $CC -shared -nostdlib -Wl,-e,0 -I. \
            kbdcustom.c kbdcustom.def -o kbdcustom.dll
          $CC -nostdlib -Wl,-e,mainCRTStartup \
            test-layout.c -lkernel32 -luser32 -o test-layout.exe
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          install -Dm755 kbdcustom.dll "$out/kbdcustom.dll"
          install -Dm755 test-layout.exe "$out/test-layout.exe"
          runHook postInstall
        '';
      };

    windowsLayout = pkgs.runCommand "wine-custom-keyboard-layout-1" {} ''
      install -Dm755 ${buildWindowsLayout pkgs.pkgsCross.mingw-msvcrt-i686 "x86"}/kbdcustom.dll \
        "$out/share/wine-custom-keyboard-layout/x86/kbdcustom.dll"
      install -Dm755 ${buildWindowsLayout pkgs.pkgsCross.mingw-msvcrt-x86_64 "x64"}/kbdcustom.dll \
        "$out/share/wine-custom-keyboard-layout/x64/kbdcustom.dll"
      install -Dm755 ${buildWindowsLayout pkgs.pkgsCross.mingw-msvcrt-x86_64 "x64"}/test-layout.exe \
        "$out/share/wine-custom-keyboard-layout/test-layout.exe"
    '';

    installWindowsLayout = pkgs.writeShellApplication {
      name = "install-battlenet-keyboard-layout";
      runtimeInputs = [pkgs.coreutils pkgs.gnugrep pkgs.procps pkgs.steam-run];
      text = ''
        prefix="''${1:-$HOME/Games/battlenet}"
        prefix="$(realpath -m "$prefix")"

        if [[ ! -d "$prefix/drive_c/windows" ]]; then
          echo "Battle.net Wine prefix not found: $prefix" >&2
          exit 1
        fi

        for process in $(pgrep -u "$(id -u)" || true); do
          if { grep -zFxq "WINEPREFIX=$prefix" "/proc/$process/environ"; } 2>/dev/null; then
            echo "Stop Battle.net and its Wine processes before installing." >&2
            exit 1
          fi
        done

        shopt -s nullglob
        wines=("$HOME"/.local/share/Steam/compatibilitytools.d/GE-Proton*/files/bin/wine)
        if (( ''${#wines[@]} != 1 )); then
          echo "Expected exactly one GE-Proton installation, found ''${#wines[@]}." >&2
          exit 1
        fi
        wine="''${wines[0]}"
        wineserver="$(dirname "$wine")/wineserver"

        install -Dm755 \
          "${windowsLayout}/share/wine-custom-keyboard-layout/x64/kbdcustom.dll" \
          "$prefix/drive_c/windows/system32/kbdcustom.dll"
        install -Dm755 \
          "${windowsLayout}/share/wine-custom-keyboard-layout/x86/kbdcustom.dll" \
          "$prefix/drive_c/windows/syswow64/kbdcustom.dll"

        registry="$prefix/drive_c/kbdcustom.reg"
        cat > "$registry" <<'REGISTRY'
        Windows Registry Editor Version 5.00

        [HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Keyboard Layouts\00000409]
        "Layout File"="kbdcustom.dll"
        "Layout Text"="Custom US with aa-oo-ae"
        REGISTRY

        WINEPREFIX="$prefix" WINEDEBUG=-all steam-run "$wine" regedit /S 'C:\kbdcustom.reg'
        rm -f "$registry"

        WINEPREFIX="$prefix" WINEDEBUG=-all steam-run "$wine" \
          "${windowsLayout}/share/wine-custom-keyboard-layout/test-layout.exe"
        WINEPREFIX="$prefix" WINEDEBUG=-all steam-run "$wineserver" -k || true

        echo "Installed and validated the custom keyboard layout in $prefix"
      '';
    };
  in {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    environment.systemPackages = [installWindowsLayout];

    home-manager.users.jacob = {...}: {
      xdg.configFile."xkb/symbols/custom".text =
        builtins.readFile ./custom;
    };
  };
}
