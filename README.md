# madOS Kernel

Linux kernel with BORE scheduler for madOS, optimized for desktop responsiveness.

## Features

- **BORE Scheduler**: Burst-Oriented Response Enhancer for improved interactivity
- **1000Hz Tickrate**: Lower latency compared to default 250Hz
- **NVMe + Btrfs built-in**: No initramfs dependency for these critical features
- **x86-64-v3 optimizations**: Better performance on modern CPUs
- **Steam Deck / Handheld support**: Pre-configured for portable devices

## Installation

### From Pre-built Package (Recommended)

```bash
# Add madOS repository to pacman.conf
[macros]
Server = https://github.com/madoslinux/mados-kernel/releases/download/$VERSION

# Or download directly from Releases
wget https://github.com/madoslinux/mados-kernel/releases/download/v6.12.1.zen1-1/linux-mados-zen-6.12.1.zen1-1-x86_64.pkg.tar.zst
pacman -U linux-mados-zen-*.pkg.tar.zst
```

### From Source

```bash
# Clone this repository
git clone https://github.com/madoslinux/mados-kernel.git
cd mados-kernel

# Install dependencies
sudo pacman -Syu --needed base-devel bc cpio gettext libelf pahole perl python tar xz zstd git

# Build the package
makepkg -si
```

## Kernel Versions

| Version | Base | Scheduler | Description |
|---------|------|-----------|-------------|
| 6.12.1.zen1-mados | linux-zen 6.12.1 | BORE | Current stable with BORE |

## Kernel Configuration

Built-in features:
- `CONFIG_BTRFS_FS=y` - Btrfs support (built-in, not module)
- `CONFIG_BLK_DEV_NVME=y` - NVMe support (built-in)
- `CONFIG_SCHED_BORE=y` - BORE scheduler
- `CONFIG_HZ_1000=y` - 1000Hz tickrate
- `CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y` - GCC optimizations

## Troubleshooting

### Kernel doesn't boot
- Ensure your bootloader is configured to use `/boot/vmlinuz-linux-mados-zen`
- Regenerate initramfs: `mkinitcpio -P`

### NVMe not detected
- Verify CONFIG_BLK_DEV_NVME=y in /boot/config-linux-mados-zen
- Check dmesg for NVMe errors

### Btrfs not working
- Ensure Btrfs is built-in (CONFIG_BTRFS_FS=y, not =m)
- Check /boot/config-linux-mados-zen

## Building Locally

### Requirements
- Arch Linux or derivative
- ~20GB disk space for build
- ~30-60 minutes compile time
- 8GB+ RAM recommended

### Build Steps
```bash
# Install dependencies
sudo pacman -Syu --needed base-devel bc cpio gettext libelf pahole perl python tar xz zstd git

# Clone and build
git clone https://github.com/madoslinux/mados-kernel.git
cd mados-kernel
makepkg -s

# Install
sudo pacman -U linux-mados-zen-*.pkg.tar.zst
```

## Credits

- BORE Scheduler: [firelzrd](https://github.com/firelzrd/bore-scheduler)
- linux-zen: [zen-kernel](https://github.com/zen-kernel/zen-kernel)
- Arch Linux Kernel Team

## License

GPL-2.0-or-later
