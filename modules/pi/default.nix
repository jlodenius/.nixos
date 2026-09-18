{inputs, ...}: {
  flake.nixosModules.pi = {config, ...}: let
    c = config.colours;

    theme = {
      "$schema" = "https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
      name = "colours";
      vars = {
        inherit (c) cyan blue green red yellow magenta comment;
        text = c.foreground;
        gray = c.comment;
        dimGray = c.subtle;
        darkGray = c.selection;
        accent = c.cyan;
        selectedBg = c.selection;
        userMsgBg = c.surface;
        toolPendingBg = c.surface;
        toolSuccessBg = c.dark.green;
        toolErrorBg = c.dark.red;
        customMsgBg = c.dark.magenta;
      };
      colors = {
        accent = "accent";
        border = "blue";
        borderAccent = "cyan";
        borderMuted = "darkGray";
        success = "green";
        error = "red";
        warning = "yellow";
        muted = "gray";
        dim = "dimGray";
        text = "text";
        thinkingText = "gray";
        selectedBg = "selectedBg";
        userMessageBg = "userMsgBg";
        userMessageText = "text";
        customMessageBg = "customMsgBg";
        customMessageText = "text";
        customMessageLabel = "magenta";
        toolPendingBg = "toolPendingBg";
        toolSuccessBg = "toolSuccessBg";
        toolErrorBg = "toolErrorBg";
        toolTitle = "text";
        toolOutput = "gray";
        mdHeading = "yellow";
        mdLink = "blue";
        mdLinkUrl = "dimGray";
        mdCode = "accent";
        mdCodeBlock = "green";
        mdCodeBlockBorder = "gray";
        mdQuote = "gray";
        mdQuoteBorder = "gray";
        mdHr = "gray";
        mdListBullet = "accent";
        toolDiffAdded = "green";
        toolDiffRemoved = "red";
        toolDiffContext = "gray";
        syntaxComment = "comment";
        syntaxKeyword = "magenta";
        syntaxFunction = "blue";
        syntaxVariable = "text";
        syntaxString = "green";
        syntaxNumber = "yellow";
        syntaxType = "cyan";
        syntaxOperator = "text";
        syntaxPunctuation = "gray";
        thinkingOff = "darkGray";
        thinkingMinimal = "gray";
        thinkingLow = "blue";
        thinkingMedium = "cyan";
        thinkingHigh = "magenta";
        thinkingXhigh = "magenta";
        thinkingMax = "red";
        bashMode = "green";
      };
      export = {
        pageBg = c.background;
        cardBg = c.surface;
        infoBg = c.dark.yellow;
      };
    };
  in {
    home-manager.users.jacob = {
      pkgs,
      config,
      ...
    }: let
      claudeAgentSdk = pkgs.callPackage ./_claude-agent-sdk.nix {};
    in {
      home.packages = [
        pkgs.unstable.pi-coding-agent
        pkgs.ddgr
        pkgs.python3Packages.trafilatura
        inputs.paj.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      home.file.".pi/agent/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/modules/pi/settings.json";

      home.file.".pi/agent/APPEND_SYSTEM.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/modules/pi/APPEND_SYSTEM.md";

      home.file.".pi/agent/prompts".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/modules/pi/prompts";

      home.file.".pi/agent/local-skills".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/modules/pi/skills";

      home.file.".pi/agent/local-extensions".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/modules/pi/extensions";

      home.file.".pi/agent/skills/mattpocock".source = "${inputs.mattpocock-skills}/skills";

      home.file.".pi/agent/extensions/claude-agent-sdk".source = "${claudeAgentSdk}/lib/node_modules/pi-claude-agent-sdk";

      home.file.".pi/agent/claude-bridge.json".source = (pkgs.formats.json {}).generate "claude-bridge.json" {
        provider = {
          plan = "pro";
          longContextExtraUsage = false;
          pathToClaudeCodeExecutable = "${config.programs.claude-code.package}/bin/claude";
        };
      };

      # Paj integration
      home.sessionVariables.PAJ_PROJECT_DIRS = "${config.home.homeDirectory}/Development,${config.home.homeDirectory}/Development/work";
      home.file.".pi/agent/extensions/paj".source = "${inputs.paj}/extensions/paj";
      home.file.".pi/agent/skills/paj".source = "${inputs.paj}/skills/paj";
      home.file.".pi/agent/skills/paj-subagents".source = "${inputs.paj}/skills/paj-subagents";

      # Theme
      home.file.".pi/agent/themes/colours.json".source =
        (pkgs.formats.json {}).generate "pi-colours-theme.json" theme;
    };
  };
}
