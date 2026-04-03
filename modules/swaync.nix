{...}: {
  flake.nixosModules.swaync = {config, ...}: let
    c = config.colours;
  in {
    home-manager.users.jacob = {
      services.swaync = {
        enable = true;
        style = ''
          * {
            all: unset;
            font-size: 14px;
            font-family: "Geist Mono";
            transition: 200ms;
          }

          trough highlight {
            background: ${c.foreground};
          }

          scale trough {
            margin: 0rem 1rem;
            background-color: ${c.surface};
            min-height: 8px;
            min-width: 70px;
          }

          slider {
            background-color: ${c.blue};
          }

          .floating-notifications.background .notification-row .notification-background {
            box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px ${c.surface};
            border-radius: 12.6px;
            margin: 18px;
            background-color: ${c.background};
            color: ${c.foreground};
            padding: 0;
          }

          .floating-notifications.background .notification-row .notification-background .notification {
            padding: 7px;
            border-radius: 12.6px;
          }

          .floating-notifications.background .notification-row .notification-background .notification.critical {
            box-shadow: inset 0 0 7px 0 ${c.red};
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content {
            margin: 7px;
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
            color: ${c.foreground};
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
            color: ${c.comment};
          }

          .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
            color: ${c.foreground};
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
            min-height: 3.4em;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
            border-radius: 7px;
            color: ${c.foreground};
            background-color: ${c.surface};
            box-shadow: inset 0 0 0 1px ${c.selection};
            margin: 7px;
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.surface};
            color: ${c.foreground};
          }

          .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.cyan};
            color: ${c.foreground};
          }

          .floating-notifications.background .notification-row .notification-background .close-button {
            margin: 7px;
            padding: 2px;
            border-radius: 6.3px;
            color: ${c.background};
            background-color: ${c.red};
          }

          .floating-notifications.background .notification-row .notification-background .close-button:hover {
            background-color: ${c.muted.red};
            color: ${c.background};
          }

          .floating-notifications.background .notification-row .notification-background .close-button:active {
            background-color: ${c.red};
            color: ${c.background};
          }

          .control-center {
            box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px ${c.surface};
            border-radius: 12.6px;
            margin: 18px;
            background-color: ${c.background};
            color: ${c.foreground};
            padding: 14px;
          }

          .control-center .widget-title > label {
            color: ${c.foreground};
            font-size: 1.3em;
          }

          .control-center .widget-title button {
            border-radius: 7px;
            color: ${c.foreground};
            background-color: ${c.surface};
            box-shadow: inset 0 0 0 1px ${c.selection};
            padding: 8px;
          }

          .control-center .widget-title button:hover {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.subtle};
            color: ${c.foreground};
          }

          .control-center .widget-title button:active {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.cyan};
            color: ${c.background};
          }

          .control-center .notification-row .notification-background {
            border-radius: 7px;
            color: ${c.foreground};
            background-color: ${c.surface};
            box-shadow: inset 0 0 0 1px ${c.selection};
            margin-top: 14px;
          }

          .control-center .notification-row .notification-background .notification {
            padding: 7px;
            border-radius: 7px;
          }

          .control-center .notification-row .notification-background .notification.critical {
            box-shadow: inset 0 0 7px 0 ${c.red};
          }

          .control-center .notification-row .notification-background .notification .notification-content {
            margin: 7px;
          }

          .control-center .notification-row .notification-background .notification .notification-content .summary {
            color: ${c.foreground};
          }

          .control-center .notification-row .notification-background .notification .notification-content .time {
            color: ${c.comment};
          }

          .control-center .notification-row .notification-background .notification .notification-content .body {
            color: ${c.foreground};
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * {
            min-height: 3.4em;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
            border-radius: 7px;
            color: ${c.foreground};
            background-color: ${c.background};
            box-shadow: inset 0 0 0 1px ${c.selection};
            margin: 7px;
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.surface};
            color: ${c.foreground};
          }

          .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.cyan};
            color: ${c.foreground};
          }

          .control-center .notification-row .notification-background .close-button {
            margin: 7px;
            padding: 2px;
            border-radius: 6.3px;
            color: ${c.background};
            background-color: ${c.muted.red};
          }

          .close-button {
            border-radius: 6.3px;
          }

          .control-center .notification-row .notification-background .close-button:hover {
            background-color: ${c.red};
            color: ${c.background};
          }

          .control-center .notification-row .notification-background .close-button:active {
            background-color: ${c.red};
            color: ${c.background};
          }

          .control-center .notification-row .notification-background:hover {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.subtle};
            color: ${c.foreground};
          }

          .control-center .notification-row .notification-background:active {
            box-shadow: inset 0 0 0 1px ${c.selection};
            background-color: ${c.cyan};
            color: ${c.foreground};
          }

          .notification.critical progress {
            background-color: ${c.red};
          }

          .notification.low progress,
          .notification.normal progress {
            background-color: ${c.blue};
          }

          .control-center-dnd {
            margin-top: 5px;
            border-radius: 8px;
            background: ${c.surface};
            border: 1px solid ${c.selection};
            box-shadow: none;
          }

          .control-center-dnd:checked {
            background: ${c.surface};
          }

          .control-center-dnd slider {
            background: ${c.selection};
            border-radius: 8px;
          }

          .widget-dnd {
            margin: 0px;
            font-size: 1.1rem;
          }

          .widget-dnd > switch {
            font-size: initial;
            border-radius: 8px;
            background: ${c.surface};
            border: 1px solid ${c.selection};
            box-shadow: none;
          }

          .widget-dnd > switch:checked {
            background: ${c.surface};
          }

          .widget-dnd > switch slider {
            background: ${c.selection};
            border-radius: 8px;
            border: 1px solid ${c.subtle};
          }

          .widget-mpris .widget-mpris-player {
            background: ${c.surface};
            padding: 7px;
          }

          .widget-mpris .widget-mpris-title {
            font-size: 1.2rem;
          }

          .widget-mpris .widget-mpris-subtitle {
            font-size: 0.8rem;
          }

          .widget-menubar > box > .menu-button-bar > button > label {
            font-size: 3rem;
            padding: 0.5rem 2rem;
          }

          .widget-menubar > box > .menu-button-bar > :last-child {
            color: ${c.red};
          }

          .power-buttons button:hover,
          .powermode-buttons button:hover,
          .screenshot-buttons button:hover {
            background: ${c.surface};
          }

          .control-center .widget-label > label {
            color: ${c.foreground};
            font-size: 2rem;
          }

          .widget-buttons-grid {
            padding-top: 1rem;
          }

          .widget-buttons-grid > flowbox > flowboxchild > button label {
            font-size: 2.5rem;
          }

          .widget-volume {
            padding-top: 1rem;
          }

          .widget-volume label {
            font-size: 1.5rem;
            color: ${c.cyan};
          }

          .widget-volume trough highlight {
            background: ${c.cyan};
          }

          .widget-backlight trough highlight {
            background: ${c.yellow};
          }

          .widget-backlight label {
            font-size: 1.5rem;
            color: ${c.yellow};
          }

          .widget-backlight .KB {
            padding-bottom: 1rem;
          }

          .image {
            padding-right: 0.5rem;
          }
        '';
      };
    };
  };
}
