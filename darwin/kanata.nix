{
  config,
  lib,
  pkgs,
  ...
}:
let
  userHome = config.users.users.${config.system.primaryUser}.home;
  # Use the driver protocol version expected by this Kanata build.
  karabinerDk = pkgs.kanata.darwinDriver;
  managerParentDir = "/Applications/.Nix-Karabiner-DriverKit";
  managerApp = "${managerParentDir}/.Karabiner-VirtualHIDDevice-Manager.app";
in
{
  # Adapted from chenxin-yan/nix-dotfiles at c98b6c5071d336cef8ba1ab980b15ba8450cf37e.
  # Keep Karabiner-Elements installed and its profile intact for switching back,
  # but disable its remapping services while Kanata owns the keyboard.
  environment.systemPackages = [
    pkgs.kanata
    karabinerDk
  ];

  system.activationScripts.preActivation.text = lib.mkAfter ''
    kanataUserId=$(/usr/bin/id -u ${lib.escapeShellArg config.system.primaryUser})
    for service in \
      org.pqrs.service.agent.Karabiner-Core-Service-rev2 \
      org.pqrs.service.agent.Karabiner-Console-User-Server; do
      /bin/launchctl disable "gui/$kanataUserId/$service"
      /bin/launchctl bootout "gui/$kanataUserId/$service" 2>/dev/null || true
    done
    /bin/launchctl disable system/org.pqrs.service.daemon.Karabiner-Core-Service
    /bin/launchctl bootout system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true

    # Replace the existing driver daemon once; later rebuilds leave ours running.
    if ! /bin/launchctl print system/org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon 2>/dev/null | /usr/bin/grep -Fq '${karabinerDk}/'; then
      /bin/launchctl bootout system/org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon 2>/dev/null || true
    fi

    # macOS requires the system extension's app to be outside /nix/store.
    /bin/mkdir -p ${managerParentDir}
    /bin/rm -rf ${managerApp}
    /bin/cp -R "${karabinerDk}/Applications/.Karabiner-VirtualHIDDevice-Manager.app" ${managerParentDir}/
  '';

  launchd.daemons.kanata.serviceConfig = {
    ProgramArguments = [
      "${pkgs.kanata}/bin/kanata"
      "--cfg"
      "${userHome}/.config/kanata/kanata.kbd"
    ];
    KeepAlive = true;
    RunAtLoad = true;
    UserName = "root";
    StandardOutPath = "${userHome}/Library/Logs/kanata.log";
    StandardErrorPath = "${userHome}/Library/Logs/kanata.error.log";
  };

  launchd.daemons.karabiner-vhiddaemon = {
    command = ''"${karabinerDk}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"'';
    serviceConfig = {
      Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon";
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
    };
  };

  launchd.daemons.karabiner-vhidmanager = {
    command = ''"${managerApp}/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate'';
    serviceConfig = {
      Label = "org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Manager";
      RunAtLoad = true;
    };
  };
}
