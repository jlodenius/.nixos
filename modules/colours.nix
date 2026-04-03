{...}: {
  flake.nixosModules.colours = {lib, ...}: {
    options.colours = lib.mkOption {
      type = lib.types.attrs;
      description = "Global colour palette";
      default = {
        # Base UI
        background = "#292522";
        surface = "#34302C";
        selection = "#403A36";
        subtle = "#867462";
        comment = "#C1A78E";
        foreground = "#ECE1D7";

        # Bright accents
        red = "#D47766";
        yellow = "#EBC06D";
        green = "#85B695";
        cyan = "#89B3B6";
        blue = "#A3A9CE";
        magenta = "#CF9BC2";

        # Muted accents
        muted = {
          red = "#BD8183";
          yellow = "#E49B5D";
          green = "#78997A";
          cyan = "#7B9695";
          blue = "#7F91B2";
          magenta = "#B380B0";
        };

        # Dark accents
        dark = {
          red = "#7D2A2F";
          yellow = "#8B7449";
          green = "#233524";
          cyan = "#253333";
          blue = "#273142";
          magenta = "#422741";
        };
      };
    };
  };
}
