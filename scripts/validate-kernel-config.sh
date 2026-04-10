#!/usr/bin/env bash
set -euo pipefail

cfg_file="${1:-src/build-generic/.config}"

if [[ ! -f "$cfg_file" ]]; then
  printf 'Could not find generated config: %s\n' "$cfg_file" >&2
  exit 1
fi

check_cfg() {
  local pattern="$1"
  local message="$2"

  if ! grep -Eq "$pattern" "$cfg_file"; then
    printf 'Validation failed: %s\n' "$message" >&2
    printf 'Pattern: %s\n' "$pattern" >&2
    printf 'Config: %s\n' "$cfg_file" >&2
    exit 1
  fi
}

check_cfg '^CONFIG_X86_64=y$' 'CONFIG_X86_64 must be enabled for target architecture'
check_cfg '^# CONFIG_X86_NATIVE_CPU is not set$' 'CONFIG_X86_NATIVE_CPU must be disabled for Atom+ compatibility'
check_cfg '^CONFIG_PREEMPT=y$' 'CONFIG_PREEMPT must be enabled for desktop responsiveness'
check_cfg '^CONFIG_HZ=1000$' 'CONFIG_HZ must remain at 1000 for current desktop policy'

check_cfg '^CONFIG_EFI=y$' 'CONFIG_EFI must be enabled for UEFI boot'
check_cfg '^CONFIG_EFI_STUB=y$' 'CONFIG_EFI_STUB must be enabled for EFI stub boot'
check_cfg '^CONFIG_DRM_SIMPLEDRM=y$' 'CONFIG_DRM_SIMPLEDRM must be enabled for early graphics'
check_cfg '^CONFIG_FRAMEBUFFER_CONSOLE=y$' 'CONFIG_FRAMEBUFFER_CONSOLE must be enabled for early console'

check_cfg '^CONFIG_SATA_AHCI=y$' 'CONFIG_SATA_AHCI must be built-in for broad storage boot paths'
check_cfg '^CONFIG_BLK_DEV_NVME=y$' 'CONFIG_BLK_DEV_NVME must be built-in for modern storage boot paths'
check_cfg '^CONFIG_USB_XHCI_HCD=y$' 'CONFIG_USB_XHCI_HCD must be built-in for modern USB boot paths'
check_cfg '^CONFIG_USB_EHCI_HCD=y$' 'CONFIG_USB_EHCI_HCD must be built-in for older USB controllers'
check_cfg '^CONFIG_EXT4_FS=y$' 'CONFIG_EXT4_FS must be built-in for common root filesystems'
check_cfg '^CONFIG_VFAT_FS=y$' 'CONFIG_VFAT_FS must be built-in for EFI system partitions'
check_cfg '^CONFIG_ISO9660_FS=y$' 'CONFIG_ISO9660_FS must be built-in for ISO/live media paths'
check_cfg '^CONFIG_SQUASHFS=y$' 'CONFIG_SQUASHFS must be built-in for live media support'
check_cfg '^CONFIG_ZSMALLOC=m$' 'CONFIG_ZSMALLOC should be enabled as module for zram support'
check_cfg '^CONFIG_ZRAM=m$' 'CONFIG_ZRAM should be enabled as module'

check_cfg '^CONFIG_CFG80211=m$' 'CONFIG_CFG80211 should be enabled as module for Wi-Fi stack support'
check_cfg '^CONFIG_MAC80211=m$' 'CONFIG_MAC80211 should be enabled as module for Wi-Fi stack support'
check_cfg '^CONFIG_RTW88_CORE=m$' 'CONFIG_RTW88_CORE must be enabled as module for Realtek rtw88'
check_cfg '^CONFIG_RTW88_PCI=m$' 'CONFIG_RTW88_PCI must be enabled as module for Realtek rtw88 PCI adapters'
check_cfg '^CONFIG_RTW88_8723DE=m$' 'CONFIG_RTW88_8723DE must be enabled as module for Realtek 8723DE support'
check_cfg '^CONFIG_RTW89_CORE=m$' 'CONFIG_RTW89_CORE should be enabled as module for modern Realtek support'
check_cfg '^CONFIG_ATH10K_PCI=m$' 'CONFIG_ATH10K_PCI should be enabled as module for common Atheros PCI adapters'
check_cfg '^CONFIG_ATH11K_PCI=m$' 'CONFIG_ATH11K_PCI should be enabled as module for common Wi-Fi 6 Atheros PCI adapters'
check_cfg '^CONFIG_BRCMFMAC_PCIE=y$' 'CONFIG_BRCMFMAC_PCIE should be enabled for Broadcom PCIe FullMAC adapters'
check_cfg '^CONFIG_MT7921E=m$' 'CONFIG_MT7921E should be enabled as module for common MediaTek PCIe adapters'

printf 'Kernel config validation passed: %s\n' "$cfg_file"
