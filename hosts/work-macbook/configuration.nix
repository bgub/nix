{
  pkgs,
  ...
}:
{
  imports = [
    ../../platforms/darwin.nix
  ];

  networking.hostName = "work-macbook";

  home-manager.users.nebrelbug = {
    # home-manager packages and configuration
    home.packages = with pkgs; [
      graphite-cli
    ];

    programs = {
      # host-specific shell aliases, etc.
      zsh = {
        initContent = ''
          # Source Next.js development utilities
          [ -f ~/.config/nix/hosts/work-macbook/nextjs-utils.sh ] && source ~/.config/nix/hosts/work-macbook/nextjs-utils.sh
        '';
      };
    };
  };
}
