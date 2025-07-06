_: {
  programs.git = {
    enable = true;
    userName = "Ben Gubler";
    userEmail = "hello@bengubler.com";

    lfs.enable = true;

    ignores = [ "**/.DS_STORE" ];

    extraConfig = {
      github = {
        user = "nebrelbug";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
