# madOS Kernel

Linux kernel packages for madOS with one generic zen-based flavor:

- `linux-mados`: broad x86_64 compatibility (Intel Atom 64-bit and newer)

Both flavors are configured to support Plymouth reliably during early boot.

## Goals

- Boot across a wide range of x86_64 hardware
- Keep desktop responsiveness (1000Hz + preemptive scheduling)
- Ensure early graphics stack is available for Plymouth splash

## Packages

- `linux-mados`
- `linux-mados-headers`

## Build From Source

```bash
sudo pacman -Syu --needed base-devel bc cpio gettext libelf pahole perl python tar xz zstd git ccache ncurses clang lld llvm binutils
git clone https://github.com/madoslinux/mados-kernel.git
cd mados-kernel
makepkg -s
```

## Install

```bash
sudo pacman -U ./linux-mados-*.pkg.tar.* ./linux-mados-headers-*.pkg.tar.*
```

## Plymouth Requirements

Plymouth needs both kernel-side and initramfs-side support.

1. Ensure your initramfs hooks include `plymouth` and `kms`.
2. Regenerate initramfs after installing a new kernel:

```bash
sudo mkinitcpio -P
```

3. Use a bootloader command line with `splash` (and typically `quiet`).

Example (`/etc/mkinitcpio.conf`) hooks with systemd initramfs:

```bash
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems plymouth fsck)
```

## Kernel Config Strategy

Configuration is generated from `x86_64_defconfig` and then layered with fragments:

- `config.base`: compatibility-oriented baseline
- `config.plymouth`: early graphics and splash-related options

This keeps the config reproducible and avoids long, stale monolithic configs.

## CI Validation

GitHub Actions now validates:

- Package build via `makepkg`
- Key kernel symbols for Atom x86_64+ compatibility and Plymouth
- QEMU smoke boot for `linux-mados` in BIOS and UEFI mode using a tiny initramfs

The smoke test confirms early boot execution path (`SMOKE_OK`) and catches hard boot regressions quickly.

## Local Pre-Push Validation

To avoid spending GitHub Actions minutes on preventable failures, this repository includes local checks:

- `.git/hooks/pre-push` runs `scripts/precommit-build-check.sh` before any push.
- The script runs `makepkg -s --noconfirm` and then validates key config symbols.
- If required build dependencies are missing, it fails and shows the exact `pacman` command to install them.

This check is strict by design and must pass before pushing.

Validated symbol policy covers:

- Generic CPU baseline for broad x86_64 support (`CONFIG_GENERIC_CPU=y`, no `MNATIVE`)
- Boot-critical storage and filesystem symbols as built-in (`AHCI`, `NVMe`, `ext4`, `vfat`, `iso9660`, `squashfs`)
- Early graphics/console path needed by installer and Plymouth (`simpledrm`, framebuffer console)
- UEFI boot symbols (`EFI`, `EFI_STUB`)

## Troubleshooting

- No splash shown:
  - Verify `HOOKS` contain `kms` and `plymouth`
  - Verify kernel cmdline includes `splash`
  - Rebuild initramfs with `mkinitcpio -P`
- Hardware-specific issues:
  - Verify firmware, initramfs hooks, and bootloader configuration first

## Credits

- zen-kernel team
- Arch Linux kernel tooling

## License

GPL-2.0-or-later
