{
  description = "NixOS configuration - dendritic pattern with flake-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stockfin = {
      url = "github:jlodenius/stockfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mlqs = {
      url = "github:daphen/mlqs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paj = {
      url = "git+file:///home/jacob/Development/Paj/paj?rev=3f416b11acd6491c47c2b539d80924a4877af0b6";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paj-rc = {
      url = "github:jlodenius/paj-rc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    paj-captain.url = "git+file:///home/jacob/Development/Paj/paj-captain?rev=1fbb794355793e01fb3fe1c9346748a4c6a4d4e6";
    paj-voice.url = "git+file:///home/jacob/Development/Paj/paj-voice?rev=2727e468fca236104a09b3098ceeba75f869b5f4";

    claude-agent-sdk = {
      url = "github:pi-pod/pi-claude-agent-sdk/main";
      flake = false;
    };

    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    # Neovim plugin sources
    paj-nvim = {
      url = "github:jlodenius/paj.nvim";
      flake = false;
    };

    vgit-nvim = {
      url = "github:tanvirtin/vgit.nvim";
      flake = false;
    };

    vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports =
        (inputs.import-tree ./modules).imports
        ++ (inputs.import-tree ./packages).imports
        ++ [
          ./flake-parts.nix
          ./hosts/thinkpad
          ./hosts/framework
        ];
    };
}
