_: {
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      experimental = true;
      verbose = false;
      auto_install = true;
    };

    globalConfig = {
      tools = {
        node = "lts";
        bun = "latest";
        deno = "latest";
        uv = "latest";
        rust = "stable";
      };

      env = {
        MISE_NODE_COREPACK = "true";
        COREPACK_ENABLE_STRICT = "0";
        NODE_ENV = "development";
      };

      settings = {
        python = {
          uv_venv_auto = true;
        };
      };

      hooks = {
        postinstall = [
          "corepack enable pnpm"
          "mise install --no-hooks"
        ];
      };
    };
  };
}
