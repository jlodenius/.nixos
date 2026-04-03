{...}: {
  flake.nixosModules.qutebrowser = {config, ...}: let
    c = config.colours;
  in {
    home-manager.users.jacob = {
      programs.qutebrowser = {
        enable = true;

        quickmarks = {
          yt = "https://www.youtube.com";
          z = "https://mail.zoho.eu/zm/#mail/folder/inbox";
          gm = "https://mail.google.com/mail/u/0/#inbox";
          gh = "https://github.com/jlodenius";
          maps = "https://www.google.com/maps";
          gemini = "https://gemini.google.com";
          rd = "https://www.reddit.com";
          ch = "https://www.chess.com";
        };

        keyBindings = {
          normal = {
            "<Ctrl-j>" = "completion-item-focus next";
            "<Ctrl-k>" = "completion-item-focus prev";
            "<Ctrl-h>" = "tab-prev";
            "<Ctrl-l>" = "tab-next";
            "<Ctrl-Shift-h>" = "tab-move -";
            "<Ctrl-Shift-l>" = "tab-move +";
            "<Ctrl-Shift-k>" = "tab-give";
            "<Ctrl-Shift-j>" = "tab-give 0";
            "<Ctrl-b>" = "spawn --userscript qute-rbw";
            "<Ctrl-Shift-b>" = "spawn --userscript qute-rbw --username-only";
            "<Ctrl-Shift-p>" = "spawn --userscript qute-rbw --password-only";
          };
          command = {
            "<Ctrl-j>" = "completion-item-focus next";
            "<Ctrl-k>" = "completion-item-focus prev";
          };
          insert = {
            "<Ctrl-b>" = "spawn --userscript qute-rbw";
            "<Ctrl-Shift-b>" = "spawn --userscript qute-rbw --username-only";
            "<Ctrl-Shift-p>" = "spawn --userscript qute-rbw --password-only";
          };
        };

        settings = {
          fonts.default_family = "GeistMono Nerd Font";
          fonts.default_size = "13pt";

          "tabs.padding" = {
            "top" = 6;
            "bottom" = 6;
            "left" = 16;
            "right" = 10;
          };
          tabs.indicator.width = 3;
          "tabs.indicator.padding" = {
            "top" = 4;
            "bottom" = 4;
            "left" = 2;
            "right" = 6;
          };

          colors.webpage.darkmode.enabled = false;
          colors.webpage.preferred_color_scheme = "dark";

          completion.shrink = true;
          completion.timestamp_format = "%Y-%m-%d";
          completion.use_best_match = true;

          auto_save.session = true;
          qt.args = ["disable-frame-rate-limit"];
          scrolling.smooth = true;

          content.blocking.method = "both";
          content.blocking.adblock.lists = [
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylist/easyprivacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances-cookies.txt"
          ];

          # Completion
          colors.completion.fg = c.foreground;
          colors.completion.odd.bg = c.surface;
          colors.completion.even.bg = c.background;
          colors.completion.category.fg = c.comment;
          colors.completion.category.bg = c.background;
          colors.completion.category.border.top = c.background;
          colors.completion.category.border.bottom = c.background;
          colors.completion.item.selected.fg = c.foreground;
          colors.completion.item.selected.bg = c.selection;
          colors.completion.item.selected.border.top = c.selection;
          colors.completion.item.selected.border.bottom = c.selection;
          colors.completion.item.selected.match.fg = c.yellow;
          colors.completion.match.fg = c.yellow;
          colors.completion.scrollbar.fg = c.subtle;
          colors.completion.scrollbar.bg = c.background;

          # Context menu
          colors.contextmenu.disabled.bg = c.surface;
          colors.contextmenu.disabled.fg = c.subtle;
          colors.contextmenu.menu.bg = c.background;
          colors.contextmenu.menu.fg = c.foreground;
          colors.contextmenu.selected.bg = c.selection;
          colors.contextmenu.selected.fg = c.foreground;

          # Downloads
          colors.downloads.bar.bg = c.background;
          colors.downloads.start.fg = c.foreground;
          colors.downloads.start.bg = c.blue;
          colors.downloads.stop.fg = c.foreground;
          colors.downloads.stop.bg = c.green;
          colors.downloads.error.fg = c.red;

          # Hints
          colors.hints.fg = c.background;
          colors.hints.bg = c.yellow;
          colors.hints.match.fg = c.subtle;

          # Key hints
          colors.keyhint.fg = c.foreground;
          colors.keyhint.suffix.fg = c.yellow;
          colors.keyhint.bg = c.background;

          # Messages
          colors.messages.error.fg = c.foreground;
          colors.messages.error.bg = c.red;
          colors.messages.error.border = c.red;
          colors.messages.warning.fg = c.foreground;
          colors.messages.warning.bg = c.muted.yellow;
          colors.messages.warning.border = c.muted.yellow;
          colors.messages.info.fg = c.foreground;
          colors.messages.info.bg = c.background;
          colors.messages.info.border = c.background;

          # Prompts
          colors.prompts.fg = c.foreground;
          colors.prompts.border = c.selection;
          colors.prompts.bg = c.surface;
          colors.prompts.selected.fg = c.foreground;
          colors.prompts.selected.bg = c.selection;

          # Status bar
          colors.statusbar.normal.fg = c.foreground;
          colors.statusbar.normal.bg = c.background;
          colors.statusbar.insert.fg = c.background;
          colors.statusbar.insert.bg = c.green;
          colors.statusbar.passthrough.fg = c.background;
          colors.statusbar.passthrough.bg = c.blue;
          colors.statusbar.private.fg = c.foreground;
          colors.statusbar.private.bg = c.surface;
          colors.statusbar.command.fg = c.foreground;
          colors.statusbar.command.bg = c.background;
          colors.statusbar.command.private.fg = c.foreground;
          colors.statusbar.command.private.bg = c.background;
          colors.statusbar.caret.fg = c.background;
          colors.statusbar.caret.bg = c.magenta;
          colors.statusbar.caret.selection.fg = c.background;
          colors.statusbar.caret.selection.bg = c.magenta;
          colors.statusbar.progress.bg = c.blue;
          colors.statusbar.url.fg = c.foreground;
          colors.statusbar.url.error.fg = c.red;
          colors.statusbar.url.hover.fg = c.comment;
          colors.statusbar.url.success.http.fg = c.subtle;
          colors.statusbar.url.success.https.fg = c.green;
          colors.statusbar.url.warn.fg = c.muted.yellow;

          # Tabs
          colors.tabs.bar.bg = c.background;
          colors.tabs.indicator.start = c.yellow;
          colors.tabs.indicator.stop = c.yellow;
          colors.tabs.indicator.error = c.red;
          colors.tabs.odd.fg = c.comment;
          colors.tabs.odd.bg = c.background;
          colors.tabs.even.fg = c.comment;
          colors.tabs.even.bg = c.background;
          colors.tabs.pinned.odd.fg = c.foreground;
          colors.tabs.pinned.odd.bg = c.background;
          colors.tabs.pinned.even.fg = c.foreground;
          colors.tabs.pinned.even.bg = c.background;
          colors.tabs.pinned.selected.odd.fg = c.foreground;
          colors.tabs.pinned.selected.odd.bg = c.selection;
          colors.tabs.pinned.selected.even.fg = c.foreground;
          colors.tabs.pinned.selected.even.bg = c.selection;
          colors.tabs.selected.odd.fg = c.foreground;
          colors.tabs.selected.odd.bg = c.selection;
          colors.tabs.selected.even.fg = c.foreground;
          colors.tabs.selected.even.bg = c.selection;
        };
      };

      # Bookmarks
      xdg.configFile."qutebrowser/bookmarks/urls".text = let
        bookmarks = {
          sis = [
            ["sis/repos" "https://dev.azure.com/swedishinstituteforstandards/_git/sis-frontend"]
            ["sis/teams" "https://teams.cloud.microsoft"]
            ["sis/time" "https://my355752-sso.sapbydesign.com/sap/ap/ui/repository/SAP_UI/HTMLOBERON5/client.html"]
            ["sis/jira" "https://sisswe.atlassian.net/jira/software/c/projects/SU/boards/24/backlog"]
            ["sis/azure" "https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.App%2FcontainerApps"]
            ["sis/timereport" "https://my.kleer.se/web2/time-reporting/month"]
            ["sis/viewer" "https://dev-viewer.standard.sis.se"]
            ["sis/viewer/test" "https://viewer-tst.standard.sis.se"]
            ["sis/viewer/swagger" "https://api-dev.standard.sis.se/swagger/index.html"]
            ["sis/mol" "https://mol-dev.sis.se"]
            ["sis/mol-admin" "https://mol-admin-dev.sis.se"]
          ];
          caesari = [
            ["caesari/gh" "https://github.com/caesariab/caesari2/pulls"]
          ];
          other = [
            ["sports" "http://www.fawanews.sc"]
          ];
        };
        toLine = pair: "${builtins.elemAt pair 1} ${builtins.elemAt pair 0}";
        all = builtins.concatLists (builtins.attrValues bookmarks);
      in
        builtins.concatStringsSep "\n" (map toLine all);

      # Greasemonkey
      xdg.configFile."qutebrowser/greasemonkey/youtube_adblock.js".source = ./youtube_adblock.js;

      # Userscript
      xdg.configFile."qutebrowser/userscripts/qute-rbw" = {
        executable = true;
        source = ./qute-rbw;
      };
    };
  };
}
