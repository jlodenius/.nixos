{...}: {
  flake.nixosModules.yazi = {config, ...}: let
    c = config.colours;
  in {
    home-manager.users.jacob = {
      programs.yazi = {
        enable = true;

        settings = {
          opener.edit = [
            {
              run = ''${"\${EDITOR:-nvim}"} "$@"'';
              desc = "$EDITOR";
              block = true;
              "for" = "unix";
            }
          ];
          tasks = {
            micro_workers = 1;
            macro_workers = 1;
            image_alloc = 53687091;
            image_bound = [0 0];
          };
        };

        theme = {
          mgr = {
            cwd = {fg = c.cyan;};
            hovered = {
              reversed = true;
              bold = true;
            };
            preview_hovered = {underline = true;};
            find_keyword = {
              fg = c.green;
              italic = true;
            };
            find_position = {
              fg = c.yellow;
              bg = "reset";
              italic = true;
            };
            marker_copied = {
              fg = c.green;
              bg = c.green;
            };
            marker_cut = {
              fg = c.magenta;
              bg = c.magenta;
            };
            marker_marked = {
              fg = c.cyan;
              bg = c.cyan;
            };
            marker_selected = {
              fg = c.foreground;
              bg = c.foreground;
            };
            tab_active = {
              fg = c.background;
              bg = c.comment;
            };
            tab_inactive = {
              fg = c.comment;
              bg = c.selection;
            };
            tab_width = 1;
            count_copied = {
              fg = c.background;
              bg = c.green;
            };
            count_cut = {
              fg = c.background;
              bg = c.magenta;
            };
            count_selected = {
              fg = c.background;
              bg = c.foreground;
            };
            border_symbol = "│";
            border_style = {fg = c.subtle;};
          };

          mode = {
            normal_main = {
              fg = c.background;
              bg = c.comment;
              bold = true;
            };
            normal_alt = {
              fg = c.comment;
              bg = c.selection;
            };
            select_main = {
              fg = c.background;
              bg = c.yellow;
              bold = true;
            };
            select_alt = {
              fg = c.yellow;
              bg = c.selection;
            };
            unset_main = {
              fg = c.background;
              bg = c.green;
              bold = true;
            };
            unset_alt = {
              fg = c.green;
              bg = c.selection;
            };
          };

          status = {
            sep_left = {
              open = "";
              close = "";
            };
            sep_right = {
              open = "";
              close = "";
            };
            overall = {};
            progress_label = {
              fg = c.foreground;
              bold = true;
            };
            progress_normal = {
              fg = c.subtle;
              bg = c.surface;
            };
            progress_error = {
              fg = c.red;
              bg = c.surface;
            };
            perm_type = {fg = c.subtle;};
            perm_read = {fg = c.green;};
            perm_write = {fg = c.red;};
            perm_exec = {fg = c.green;};
            perm_sep = {fg = c.subtle;};
          };

          pick = {
            border = {fg = c.blue;};
            active = {
              fg = c.magenta;
              bold = true;
            };
            inactive = {};
          };

          input = {
            border = {fg = c.foreground;};
            title = {};
            value = {};
            selected = {reversed = true;};
          };

          tasks = {
            border = {fg = c.subtle;};
            title = {};
            hovered = {underline = true;};
          };

          which = {
            mask = {bg = c.surface;};
            cand = {fg = c.cyan;};
            rest = {fg = c.comment;};
            desc = {fg = c.yellow;};
            separator = "  ";
            separator_style = {fg = c.subtle;};
          };

          help = {
            on = {fg = c.cyan;};
            run = {fg = c.magenta;};
            hovered = {
              reversed = true;
              bold = true;
            };
            footer = {
              fg = c.background;
              bg = c.comment;
            };
          };

          notify = {
            title_info = {fg = c.green;};
            title_warn = {fg = c.yellow;};
            title_error = {fg = c.red;};
          };

          filetype = {
            rules = [
              {
                mime = "image/*";
                fg = c.magenta;
              }
              {
                mime = "{audio,video}/*";
                fg = c.yellow;
              }
              {
                mime = "application/*zip";
                fg = c.red;
              }
              {
                mime = "application/x-{tar,bzip*,7z-compressed,xz,rar}";
                fg = c.red;
              }
              {
                mime = "application/{pdf,doc,rtf,vnd.*}";
                fg = c.green;
              }
              {
                name = "*";
                fg = c.foreground;
              }
              {
                name = "*/";
                fg = c.cyan;
              }
            ];
          };

          confirm = {
            border = {fg = c.comment;};
            title = {fg = c.cyan;};
            content = {fg = c.foreground;};
            body = {fg = c.red;};
            list = {fg = c.foreground;};
            btn_yes = {
              reversed = true;
              fg = c.foreground;
            };
            btn_no = {};
            btn_labels = ["  [Y]es  " "  (N)o  "];
          };

          cmp = {
            border = {fg = c.comment;};
            active = {
              reversed = true;
              fg = c.cyan;
            };
            inactive = {fg = c.foreground;};
          };
        };
      };
    };
  };
}
