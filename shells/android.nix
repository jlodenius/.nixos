{
  pkgs ?
    import (builtins.getFlake (toString ../.)).inputs.nixpkgs {
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    },
}: let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    toolsVersion = null;
    platformVersions = ["36"];
    buildToolsVersions = ["36.0.0"];
    includeNDK = true;
    ndkVersions = ["27.1.12297006"];
    includeCmake = true;
    cmakeVersions = ["3.22.1"];
    includeEmulator = false;
    includeSystemImages = false;
  };
  androidSdkRoot = "${androidComposition.androidsdk}/libexec/android-sdk";
in
  pkgs.mkShell {
    name = "android-dev-shell";

    packages = [
      androidComposition.androidsdk
      pkgs.jdk17
      pkgs.nodejs_22
    ];

    ANDROID_HOME = androidSdkRoot;
    ANDROID_SDK_ROOT = androidSdkRoot;
    JAVA_HOME = "${pkgs.jdk17}";
  }
