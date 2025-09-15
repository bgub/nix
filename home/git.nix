_: {
  programs.git = {
    enable = true;
    userName = "Ben Gubler";
    userEmail = "me@bengubler.com";

    lfs.enable = true;

    ignores = [ "**/.DS_STORE" ];

    extraConfig = {
      github = {
        user = "bgub";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
