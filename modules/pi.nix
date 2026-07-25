{...}: {
  flake.nixosModules.pi = {...}: {
    home-manager.users.jacob = {pkgs, ...}: {
      home.packages = [pkgs.unstable.pi-coding-agent];

      # Appended to pi's built-in system prompt (does not replace it).
      home.file.".pi/agent/APPEND_SYSTEM.md".text = ''
        # Environment
        This is a NixOS system

        # Comments
        Default to writing NO comments. Never comment self-explanatory code.
        Only write one when it genuinely adds value: non-obvious rationale, a
        workaround, a subtle constraint that isn't visible in the code. When
        in doubt, leave it out.
      '';

      # Skills: drop one folder per skill (each with a SKILL.md) into ./skills,
      # or point at a flake input once the skills repo exists (add `{inputs, ...}`
      # to the module args first).
      # home.file.".pi/agent/skills".source = ./skills;
      # home.file.".pi/agent/skills".source = inputs.pi-skills;

      # Baseline settings.json (read-only symlink; runtime /model, /theme won't
      # persist here — set defaults below instead).
      # home.file.".pi/agent/settings.json".source =
      #   (pkgs.formats.json {}).generate "pi-settings.json" {
      #     theme = "dark";
      #   };

      # Auth: run `/login` once per machine — nothing managed here.
      # trust.json: left unmanaged so per-project trust prompts still work.
    };
  };
}
