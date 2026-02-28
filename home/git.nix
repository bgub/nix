_: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [ "**/.DS_STORE" ];

    settings = {
      user = {
        name = "Ben Gubler";
        email = "me@bengubler.com";
      };
      github.user = "bgub";
      init.defaultBranch = "main";
      credential.helper = "!gh auth git-credential";
    };
  };
}
