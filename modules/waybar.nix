{...}: {
  flake.nixosModules.waybar = {
    config,
    pkgs,
    ...
  }: let
    c = config.colours;
    niri-minimap = pkgs.writeShellScript "niri-minimap" ''
      focused=$(niri msg focused-window 2>/dev/null)
      windows=$(niri msg windows 2>/dev/null)

      focused_workspace=$(echo "$focused" | grep "Workspace ID:" | awk '{print $3}')
      focused_column=$(echo "$focused" | grep "Scrolling position:" | sed 's/.*column \([0-9]*\).*/\1/')

      if [ -z "$focused_workspace" ] || [ -z "$focused_column" ]; then
        echo '{"text": "◆", "tooltip": "No active window"}'
        exit 0
      fi

      declare -A columns
      while IFS= read -r line; do
        if [[ $line =~ "Window ID" ]]; then
          current_window="$line"
          in_focused_workspace=0
        elif [[ $line =~ "Workspace ID: $focused_workspace" ]]; then
          in_focused_workspace=1
        elif [[ $in_focused_workspace -eq 1 ]] && [[ $line =~ "Scrolling position: column "([0-9]+) ]]; then
          col="''${BASH_REMATCH[1]}"
          columns[$col]=1
        fi
      done <<< "$windows"

      if [ ''${#columns[@]} -le 1 ]; then
        echo '{"text": "◆", "tooltip": "Single column"}'
        exit 0
      fi

      minimap=""
      sorted_cols=($(for col in "''${!columns[@]}"; do echo "$col"; done | sort -n))

      for col in "''${sorted_cols[@]}"; do
        if [ "$col" -eq "$focused_column" ]; then
          minimap="''${minimap}◆"
        else
          minimap="''${minimap}◇"
        fi
      done

      tooltip="WS $focused_workspace - Col $focused_column/''${sorted_cols[-1]}"
      echo "{\"text\": \"$minimap\", \"tooltip\": \"$tooltip\"}"
    '';
  in {
    home-manager.users.jacob = {
      programs.waybar = {
        enable = true;
        settings = [
          {
            layer = "top";
            position = "top";
            height = 30;
            margin = "5";

            modules-left = [
              "hyprland/workspaces"
              "niri/workspaces"
              "custom/niri-minimap"
            ];
            modules-center = ["tray"];
            modules-right = [
              "custom/stockfin"
              "network"
              "pulseaudio"
              "disk"
              "cpu"
              "temperature"
              "battery"
              "clock#time"
            ];

            pulseaudio = {
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}%";
              format-muted = " {volume}%";
              format-icons = {
                headphones = "";
                default = ["" ""];
              };
              scroll-step = 1;
              on-click = "pavucontrol";
            };

            battery = {
              interval = 10;
              states = {
                warning = 30;
                critical = 15;
              };
              format = " {capacity}%";
              format-discharging = "{icon} {capacity}%";
              format-icons = ["" "" "" "" ""];
              tooltip = true;
            };

            "clock#time" = {
              interval = 1;
              format = "{:%H:%M}";
              tooltip = false;
            };

            "clock#date" = {
              interval = 10;
              format = "{:%e %b %Y}";
              tooltip = false;
            };

            disk = {
              path = "/home";
              interval = 30;
              format = " {percentage_used}%";
            };

            cpu = {
              interval = 5;
              format = " {usage}%";
              states = {
                warning = 70;
                critical = 90;
              };
            };

            network = {
              interval = 5;
              format-wifi = " {essid}";
              format-ethernet = "󰈀 eth";
              format-disconnected = "⚠ Disconnected";
              tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            };

            "hyprland/window" = {
              format = "{}";
              max-length = 120;
            };

            "hyprland/workspaces" = {
              all-outputs = false;
              format = "{name}";
            };

            temperature = {
              critical-threshold = 80;
              interval = 5;
              format = "{icon} {temperatureC}°C";
              format-icons = ["" "" "" "" ""];
              tooltip = true;
            };

            tray = {
              icon-size = 18;
              spacing = 8;
            };

            "custom/niri-minimap" = {
              format = "{}";
              return-type = "json";
              interval = 1;
              exec = "${niri-minimap}";
              tooltip = true;
            };

            "custom/stockfin" = {
              format = " {}";
              return-type = "json";
              interval = 30;
              exec = "busctl --user get-property org.jlodenius.stockfin.Waybar /org/jlodenius/stockfin org.jlodenius.stockfin StatusJson | sed 's/s \"//;s/\"$//;s/\\\\//g'";
              on-click = "busctl --user call org.jlodenius.stockfin.Waybar /org/jlodenius/stockfin org.jlodenius.stockfin Activate";
              escape = true;
            };
          }
        ];

        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: "Geist Mono Nerd Font Propo", monospace;
            font-weight: 600;
            font-size: 15px;
            min-height: 0;
          }

          window#waybar {
            background-color: rgba(41, 37, 34, 0.5);
            color: #ffffff;
            border-radius: 4px;
          }

          #workspaces button {
            padding: 0 5px;
            color: ${c.subtle};
            background: transparent;
          }

          #workspaces button.active,
          #workspaces button.focused {
            color: #ffffff;
          }

          #workspaces button.urgent {
            color: ${c.red};
            opacity: 1;
          }

          #battery,
          #clock,
          #disk,
          #cpu,
          #network,
          #pulseaudio,
          #temperature,
          #tray,
          #custom-stockfin {
            padding: 0 12px;
            background: transparent;
            color: #ffffff;
          }

          #network.disconnected,
          #pulseaudio.muted,
          #battery.critical,
          #temperature.critical {
            color: ${c.red};
          }

          #battery.warning,
          #cpu.warning {
            color: ${c.yellow};
          }

          #custom-niri-minimap {
            padding: 0 12px;
            margin-bottom: 2px;
          }

          #custom-stockfin.bullish {
            color: ${c.green};
          }

          #custom-stockfin.bearish {
            color: ${c.red};
          }
        '';
      };
    };
  };
}
