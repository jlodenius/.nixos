{
  description = "NixOS configuration with Flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stockfin = {
      url = "github:jlodenius/stockfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    zen-browser,
    stockfin,
    ...
  }: let
    system = "x86_64-linux";

    # Add your hostnames here.
    # Nix will look for a folder in ./hosts/ with this exact name.
    hosts = ["thinkpad"];

    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts (
      name:
        nixpkgs.lib.nixosSystem {
          inherit system;

          # These are passed to BOTH nixos and home-manager modules
          specialArgs = {inherit zen-browser stockfin;};

          modules = [
            # 1. Point to the host folder
            ./hosts/${name}

            # 2. Apply the unstable overlay
            ({...}: {nixpkgs.overlays = [overlay-unstable];})

            # 3. Setup Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {inherit zen-browser stockfin;};
            }
          ];
        }
    );
  };
}
