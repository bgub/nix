_: {
  programs.git = {
    enable = true;
    userName = "Ben Gubler";
    userEmail = "nebrelbug@gmail.com";

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
