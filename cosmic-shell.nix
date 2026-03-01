{ pkgs ? import <nixpkgs> {} }:

let
  runtimeLibs = with pkgs; [
    libGL
    libxkbcommon
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    libxcb
  ];
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    dbus
    glib
    libinput
    pulseaudio
    udev
  ] ++ runtimeLibs;

  # Force-link libraries that libcosmic/iced dlopen() at runtime.
  # Same approach as libcosmicAppHook in nixos-cosmic.
  RUSTFLAGS = builtins.concatStringsSep " " (
    [ "-C link-arg=-Wl,--push-state,--no-as-needed" ]
    ++ builtins.map (lib: "-C link-arg=-l${lib}") [
      "EGL"
      "xkbcommon"
      "X11"
      "X11-xcb"
      "Xcursor"
      "Xi"
      "xcb"
      "wayland-client"
      "wayland-egl"
      "vulkan"
    ]
    ++ [ "-C link-arg=-Wl,--pop-state" ]
  );

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeLibs;
}
