#!/bin/bash
# Arch Linux Install Script — ThinkPad T480 (20L6SCSB00)
# Hardware: i5-8350U, Intel UHD 620, 32GB RAM, NVMe (Samsung PM981)
#           Intel 8265 WiFi/BT, Intel I219-LM Ethernet, EFI boot
# Target: Arch + Hyprland
#
# Run from the Arch live USB after connecting to the internet:
#   iwctl station wlan0 connect YOUR_SSID
#   curl/wget this script or type it in
#   chmod +x install-arch.sh && ./install-arch.sh

set -euo pipefail

# ============================================================
# CONFIGURATION — edit these before running
# ============================================================
DISK="/dev/nvme0n1"
HOSTNAME="sulaco"
USERNAME="sulaco"
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"
KEYMAP="us"

# Partition sizes
EFI_SIZE="512M"
SWAP_SIZE="8G"                    # 8GB swap (for 32GB RAM + hibernate)
# Remainder goes to root

# ============================================================
# PRE-FLIGHT CHECKS
# ============================================================
echo "========================================"
echo " Arch Linux Installer — ThinkPad T480"
echo "========================================"
echo ""
echo "Target disk: $DISK"
echo "Hostname:    $HOSTNAME"
echo "User:        $USERNAME"
echo "Timezone:    $TIMEZONE"
echo ""
echo "This will ERASE $DISK completely."
read -rp "Type YES to continue: " confirm
[[ "$confirm" == "YES" ]] || { echo "Aborted."; exit 1; }

# Verify EFI mode
[[ -d /sys/firmware/efi ]] || { echo "ERROR: Not booted in EFI mode."; exit 1; }

# Verify internet
ping -c 1 -W 5 archlinux.org &>/dev/null || { echo "ERROR: No internet. Connect first: iwctl station wlan0 connect SSID"; exit 1; }

# Sync clock
timedatectl set-ntp true

# ============================================================
# PARTITIONING
# ============================================================
echo ""
echo ">>> Partitioning $DISK..."

# Wipe and create new GPT
sgdisk --zap-all "$DISK"

# Create partitions
sgdisk -n 1:0:+${EFI_SIZE} -t 1:ef00 -c 1:"EFI"  "$DISK"
sgdisk -n 2:0:+${SWAP_SIZE} -t 2:8200 -c 2:"Swap" "$DISK"
sgdisk -n 3:0:0             -t 3:8300 -c 3:"Root"  "$DISK"

# Inform kernel of partition changes
partprobe "$DISK"
sleep 2

# ============================================================
# FORMATTING
# ============================================================
echo ">>> Formatting partitions..."

mkfs.fat -F32 "${DISK}p1"
mkswap "${DISK}p2"
mkfs.ext4 -F "${DISK}p3"

# ============================================================
# MOUNTING
# ============================================================
echo ">>> Mounting filesystems..."

mount "${DISK}p3" /mnt
mkdir -p /mnt/boot
mount "${DISK}p1" /mnt/boot
swapon "${DISK}p2"

# ============================================================
# BASE INSTALL
# ============================================================
echo ">>> Installing base system..."

# Ensure pacman keyring is initialized (live USB may not have it ready)
pacman-key --init
pacman-key --populate archlinux

pacstrap -K /mnt \
    base \
    base-devel \
    linux \
    linux-firmware \
    linux-headers \
    intel-ucode \
    dkms \
    networkmanager \
    bluez \
    bluez-utils \
    git \
    vim \
    nano \
    sudo \
    man-db \
    man-pages

# ============================================================
# FSTAB
# ============================================================
echo ">>> Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# ============================================================
# CHROOT SETUP
# ============================================================
echo ">>> Entering chroot for system configuration..."

cat <<'CHROOT_SCRIPT' > /mnt/chroot-setup.sh
#!/bin/bash
set -euo pipefail

HOSTNAME="__HOSTNAME__"
USERNAME="__USERNAME__"
TIMEZONE="__TIMEZONE__"
LOCALE="__LOCALE__"
KEYMAP="__KEYMAP__"
DISK="__DISK__"

# --- Timezone & Clock ---
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

# --- Locale ---
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# --- Hostname ---
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# --- Intel GPU (UHD 620) ---
pacman -S --noconfirm \
    mesa \
    vulkan-intel \
    intel-media-driver \
    libva-utils

# --- Initramfs ---
# mkinitcpio v38+ moved microcode to a hook — use the 'microcode' hook
# instead of separate initrd lines in the bootloader.
# Early KMS via i915 in MODULES for fast display init.
sed -i 's/^MODULES=.*/MODULES=(i915)/' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# --- Bootloader (systemd-boot) ---
bootctl install

cat > /boot/loader/loader.conf <<EOF
default arch.conf
timeout 3
console-mode auto
editor  no
EOF

ROOT_PARTUUID=$(blkid -s PARTUUID -o value "${DISK}p3")
SWAP_PARTUUID=$(blkid -s PARTUUID -o value "${DISK}p2")
cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=${ROOT_PARTUUID} resume=PARTUUID=${SWAP_PARTUUID} rw quiet splash
EOF

cat > /boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux (fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=PARTUUID=${ROOT_PARTUUID} resume=PARTUUID=${SWAP_PARTUUID} rw
EOF

# --- User setup ---
echo ">>> Set root password:"
passwd

useradd -m -G wheel,video,audio,input -s /bin/bash "$USERNAME"
echo ">>> Set password for $USERNAME:"
passwd "$USERNAME"

# Enable wheel group sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# --- Networking ---
systemctl enable NetworkManager
systemctl enable bluetooth

# --- Audio (PipeWire) ---
pacman -S --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    sof-firmware

# --- ThinkPad T480 specific ---

# TLP for power management (ThinkPad optimized)
# NOTE: tp_smapi is NOT compatible with the T480 (requires classic EC from
# xx00-xx30 series). The T480 uses a newer EC — use acpi_call instead.
pacman -S --noconfirm \
    tlp \
    tlp-rdw \
    acpi_call-dkms \
    ethtool \
    smartmontools

systemctl enable tlp
systemctl enable NetworkManager-dispatcher
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

# TrackPoint + Touchpad: enable enhanced event reporting (40Hz -> 135Hz)
mkdir -p /etc/modprobe.d
echo "options psmouse synaptics_intertouch=1" > /etc/modprobe.d/psmouse.conf

# Throttling fix for T480 (the 8th gen throttling issue)
# Install throttled from AUR after first boot (requires AUR helper)
# NOTE: thermald is intentionally NOT installed here because it conflicts
# with throttled. Install throttled from AUR instead (see post-boot notes).

# Firmware update support
pacman -S --noconfirm fwupd

# --- Hyprland + Wayland Desktop ---
pacman -S --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    xdg-utils \
    xdg-user-dirs \
    qt5-wayland \
    qt6-wayland \
    kitty \
    waybar \
    wofi \
    mako \
    grim \
    slurp \
    wl-clipboard \
    brightnessctl \
    playerctl \
    polkit-gnome \
    gnome-keyring \
    network-manager-applet \
    pavucontrol \
    thunar \
    ttf-font-awesome \
    noto-fonts \
    noto-fonts-emoji \
    hyprlock \
    hypridle \
    hyprpaper

# --- ProtonVPN (official repo since v4) ---
pacman -S --noconfirm proton-vpn-gtk-app networkmanager-openvpn

# --- Essential tools ---
pacman -S --noconfirm \
    chromium \
    htop \
    btop \
    fastfetch \
    openssh \
    rsync \
    unzip \
    p7zip \
    wget \
    curl \
    tree \
    feh \
    mpv \
    efibootmgr

# Enable SSH
systemctl enable sshd

# --- Set Chromium as default browser ---
su - "$USERNAME" -c "xdg-settings set default-web-browser chromium.desktop" 2>/dev/null || true

# --- Hyprland config for ThinkPad T480 ---
USERHOME="/home/$USERNAME"
mkdir -p "$USERHOME/.config/hypr"

cat > "$USERHOME/.config/hypr/hyprland.conf" <<'HYPRCONF'
# ThinkPad T480 Hyprland Config

# Monitor — Intel UHD 620 single display
monitor=,preferred,auto,1

# Execute at launch
exec-once = waybar
exec-once = mako
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = hypridle

# Environment variables for Intel GPU
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_BACKEND,wayland,x11
env = MOZ_ENABLE_WAYLAND,1

# Input — TrackPoint + TouchPad
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = true
        tap-to-click = true
        disable_while_typing = true
        scroll_factor = 0.5
    }
    sensitivity = 0
}

# General
general {
    gaps_in = 4
    gaps_out = 8
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decoration
decoration {
    rounding = 8
    blur {
        enabled = true
        size = 5
        passes = 2
    }
}

# Animations — keep light for UHD 620
animations {
    enabled = true
    bezier = snappy, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 4, snappy
    animation = windowsOut, 1, 4, default, popin 80%
    animation = fade, 1, 4, default
    animation = workspaces, 1, 3, default
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Key bindings
$mainMod = SUPER

bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, E, exit,
bind = $mainMod, V, togglefloating,
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, F, fullscreen,
bind = $mainMod, P, pseudo,
bind = $mainMod, S, togglesplit,
bind = $mainMod, Escape, exec, hyprlock

# Move focus
bind = $mainMod, H, movefocus, l
bind = $mainMod, L, movefocus, r
bind = $mainMod, K, movefocus, u
bind = $mainMod, J, movefocus, d

# Move windows
bind = $mainMod SHIFT, H, movewindow, l
bind = $mainMod SHIFT, L, movewindow, r
bind = $mainMod SHIFT, K, movewindow, u
bind = $mainMod SHIFT, J, movewindow, d

# Resize
bind = $mainMod CTRL, H, resizeactive, -40 0
bind = $mainMod CTRL, L, resizeactive, 40 0
bind = $mainMod CTRL, K, resizeactive, 0 -40
bind = $mainMod CTRL, J, resizeactive, 0 40

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# ThinkPad hardware keys
binde = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
binde = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Screenshot
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy
HYPRCONF

# --- hypridle config (lock screen + suspend on idle) ---
cat > "$USERHOME/.config/hypr/hypridle.conf" <<'HYPRIDLE'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

# Dim screen after 2.5 minutes
listener {
    timeout = 150
    on-timeout = brightnessctl -s set 10
    on-resume = brightnessctl -r
}

# Lock screen after 5 minutes
listener {
    timeout = 300
    on-timeout = loginctl lock-session
}

# Turn off display after 5.5 minutes
listener {
    timeout = 330
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

# Suspend after 15 minutes
listener {
    timeout = 900
    on-timeout = systemctl suspend
}
HYPRIDLE

# --- hyprlock config ---
cat > "$USERHOME/.config/hypr/hyprlock.conf" <<'HYPRLOCK'
background {
    monitor =
    path = screenshot
    blur_passes = 3
    blur_size = 8
}

input-field {
    monitor =
    size = 200, 50
    outline_thickness = 3
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = false
    outer_color = rgb(33ccff)
    inner_color = rgb(200, 200, 200)
    font_color = rgb(10, 10, 10)
    fade_on_empty = true
    placeholder_text = <i>Password...</i>
    hide_input = false
    position = 0, -20
    halign = center
    valign = center
}
HYPRLOCK

chown -R "$USERNAME:$USERNAME" "$USERHOME/.config"

# --- Auto-start Hyprland from TTY ---
# Create .bash_profile that sources .bashrc (Arch default behavior) and
# auto-starts Hyprland on tty1
cat > "$USERHOME/.bash_profile" <<'BASHLOGIN'
#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Auto-start Hyprland on tty1
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec Hyprland
fi
BASHLOGIN

chown "$USERNAME:$USERNAME" "$USERHOME/.bash_profile"

# --- Create XDG user directories ---
su - "$USERNAME" -c "xdg-user-dirs-update" 2>/dev/null || true

# --- Post-install notes ---
cat <<'NOTES'

============================================================
 INSTALL COMPLETE — Post-boot TODO
============================================================

1. Reboot and remove USB
2. Connect to WiFi:
     nmcli device wifi connect "SSID" password "PASS"

3. Install an AUR helper (yay):
     cd /tmp
     git clone https://aur.archlinux.org/yay-bin.git
     cd yay-bin && makepkg -si

4. Install throttled (T480 throttle fix):
     yay -S throttled
     sudo systemctl enable --now throttled

5. Install Claude Code CLI:
     curl -fsSL https://claude.ai/install.sh | sh

6. Your Hyprland config is at:
     ~/.config/hypr/hyprland.conf

7. Restore your backup files (SSH keys, etc.)

8. Update firmware:
     fwupdmgr get-devices
     fwupdmgr refresh
     fwupdmgr get-updates
     fwupdmgr update

============================================================
NOTES

CHROOT_SCRIPT

# Substitute variables into chroot script
sed -i "s/__HOSTNAME__/$HOSTNAME/g"  /mnt/chroot-setup.sh
sed -i "s/__USERNAME__/$USERNAME/g"  /mnt/chroot-setup.sh
sed -i "s|__TIMEZONE__|$TIMEZONE|g"  /mnt/chroot-setup.sh
sed -i "s/__LOCALE__/$LOCALE/g"      /mnt/chroot-setup.sh
sed -i "s/__KEYMAP__/$KEYMAP/g"      /mnt/chroot-setup.sh
sed -i "s|__DISK__|$DISK|g"          /mnt/chroot-setup.sh

chmod +x /mnt/chroot-setup.sh
arch-chroot /mnt /chroot-setup.sh

# Cleanup
rm /mnt/chroot-setup.sh

# ============================================================
# DONE
# ============================================================
echo ""
echo "========================================"
echo " Installation complete!"
echo " Run: umount -R /mnt && reboot"
echo "========================================"
