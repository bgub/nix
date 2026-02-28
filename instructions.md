# Manual Setup Instructions

## Set login keyring password to empty

Auto-login skips the greeter, so the GNOME keyring doesn't get unlocked
automatically. Run `seahorse`, right-click the "Login" keyring, change the
password, and leave the new password blank. LUKS handles encryption at rest.

## Set BIOS Fastboot to Minimal

Press F2 at the Dell logo during boot to enter BIOS. Set Fastboot to Minimal
to skip full POST hardware checks (~2-3s faster boot).

## Authenticate Tailscale

Run `sudo tailscale up` and follow the link to log in.

## Access systemd-boot menu

Boot timeout is set to 0. Hold Space during boot to show the menu.
