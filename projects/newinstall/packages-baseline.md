# Package Baseline — Post-Archinstall

Explicitly installed packages (`pacman -Qe`) as of first boot + bash session.
484 total packages (most are deps), 51 explicitly installed.

## From archinstall profile

These were selected during archinstall (i3 desktop profile + extras):

### Core
- `base`, `linux`, `linux-firmware`, `intel-ucode`
- `sudo`, `nano`, `vim`, `wget`, `git`
- `efibootmgr`, `lvm2`, `btrfs-progs`

### Desktop (i3)
- `i3-wm`, `i3blocks`, `i3lock`, `i3status`
- `dmenu`, `xorg-xinit`, `xss-lock`, `xterm`
- `lightdm`, `lightdm-gtk-greeter`
- `kitty` (terminal)

### Network
- `networkmanager`, `network-manager-applet`
- `iwd`, `wireless_tools`

### Audio (pipewire)
- `pipewire`, `pipewire-alsa`, `pipewire-jack`, `pipewire-pulse`
- `gst-plugin-pipewire`, `wireplumber`, `libpulse`

### Bluetooth
- `bluez`, `bluez-utils`

### Intel GPU
- `intel-media-driver`, `libva-intel-driver`, `vulkan-intel`

### System
- `htop`, `cronie`, `smartmontools`, `power-profiles-daemon`
- `sof-firmware` (audio firmware)
- `timeshift` (backups)
- `zram-generator`
- `xdg-utils`

## Installed manually (bash session)

```bash
sudo pacman -S firefox
sudo pacman -S github-cli
sudo pacman -S chezmoi
sudo pacman -S zsh
```

## Not yet installed (needed)

- AUR helper (paru/yay)
- Nerd fonts
- Dev tools (python, node, rust, etc.)
- Claude Code deps (node/npm — installed via installer?)
