_: {
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      experimental = true;
      verbose = false;
      auto_install = true;
    };
  };
}
