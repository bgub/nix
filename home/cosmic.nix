{ ... }:
{
  wayland.desktopManager.cosmic = {
    enable = true;

    compositor = {
      autotile = true;
      xkb_config = {
        rules = "";
        model = "";
        layout = "us,cz,ara";
        variant = ",qwerty,";
        options = {
          __type = "optional";
          value = "compose:ralt,caps:escape";
        };
        repeat_delay = 600;
        repeat_rate = 25;
      };
    };

    applets.time.settings.military_time = true;

    panels = [
      {
        name = "Panel";
        margin = 0;
        plugins_center = {
          __type = "optional";
          value = [
            "com.github.bgub.CosmicExtAppletPomodoro"
            "com.system76.CosmicAppletTime"
            "com.github.bgub.CosmicExtAppletVigil"
          ];
        };
        plugins_wings = {
          __type = "optional";
          value = {
            __type = "tuple";
            value = [
              [
                "com.system76.CosmicAppletWorkspaces"
                "com.github.bgub.CosmicExtAppletSysmon"
                "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager"
                "com.system76.CosmicAppletMinimize"
              ]
              [
                "com.system76.CosmicAppletInputSources"
                "com.system76.CosmicAppletStatusArea"
                "com.system76.CosmicAppletTiling"
                "com.system76.CosmicAppletAudio"
                "com.system76.CosmicAppletBluetooth"
                "com.system76.CosmicAppletNetwork"
                "com.system76.CosmicAppletBattery"
                "com.system76.CosmicAppletNotifications"
                "com.system76.CosmicAppletPower"
              ]
            ];
          };
        };
      }
    ];

    # Avoid cosmic-manager's shortcut type parser, which currently uses a
    # non-POSIX regex rejected by Nix's regex engine.
    shortcuts = null;

    configFile."com.system76.CosmicSettings.Shortcuts" = {
      version = 1;
      entries.custom = {
        __type = "raw";
        value = ''
          {
              (description: Some("Screenshot"), key: "Print", modifiers: []): Spawn("flameshot gui --clipboard"),
              (description: Some("Open Terminal"), key: "Return", modifiers: [Super]): Spawn("cosmic-term"),
              (key: "backslash", modifiers: [Super]): Minimize,
              (description: Some("Voice to text"), key: "space", modifiers: [Alt]): Spawn("voxtype record toggle"),
          }
        '';
      };
    };
  };

  programs.cosmic-term = {
    enable = true;
    profiles = [
      {
        hold = false;
        is_default = true;
        name = "Default";
        syntax_theme_dark = "COSMIC Dark";
        syntax_theme_light = "COSMIC Light";
      }
    ];
    settings = {
      font_name = "FiraCode Nerd Font Mono";
      show_headerbar = false;
    };
  };
}
