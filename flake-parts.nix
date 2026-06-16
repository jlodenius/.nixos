{inputs, ...}: {
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  # perSystem pkgs (used to build the neovim wrapper) needs the same
  # allowUnfree as the system config — some vim plugins (e.g. transparent.nvim)
  # are flagged unfree in nixpkgs.
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}
