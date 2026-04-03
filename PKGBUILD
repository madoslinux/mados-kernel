# madOS Kernel packages
# Maintainer: madOS Team

pkgbase=linux-mados
pkgname=(
  linux-mados
  linux-mados-headers
)
pkgrel=1
pkgver=6.19.10.zen1
_kernelver=6.19.10-zen1
pkgdesc="madOS kernels: broad-compat and performance flavors with Plymouth-ready defaults"
url="https://github.com/madoslinux/mados-kernel"
arch=(x86_64)
license=(GPL-2.0-or-later)
makedepends=(
  bc
  cpio
  gettext
  libelf
  pahole
  perl
  python
  tar
  xz
  zstd
  git
  ccache
  ncurses
  clang
  lld
  llvm
  binutils
)
options=(!strip)
source=(
  config.base
  config.plymouth
)
sha256sums=(
  SKIP
  SKIP
)

_set_kcfg() {
  local cfg_file="$1"
  local key="$2"
  local val="$3"

  sed -i -E \
    -e "s|^${key}=.*$|${key}=${val}|" \
    -e "s|^# ${key} is not set$|${key}=${val}|" \
    "$cfg_file"

  if ! grep -q "^${key}=" "$cfg_file"; then
    printf '%s=%s\n' "$key" "$val" >>"$cfg_file"
  fi
}

_disable_kcfg() {
  local cfg_file="$1"
  local key="$2"

  sed -i -E \
    -e "s|^${key}=.*$|# ${key} is not set|" \
    "$cfg_file"

  if ! grep -q "^# ${key} is not set$" "$cfg_file"; then
    printf '# %s is not set\n' "$key" >>"$cfg_file"
  fi
}

_apply_fragment() {
  local cfg_file="$1"
  local fragment="$2"

  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" =~ ^([A-Z0-9_]+)=(.*)$ ]]; then
      _set_kcfg "$cfg_file" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    elif [[ "$line" =~ ^#\ ([A-Z0-9_]+)\ is\ not\ set$ ]]; then
      _disable_kcfg "$cfg_file" "${BASH_REMATCH[1]}"
    fi
  done <"$fragment"
}

_configure_kernel() {
  local outdir="$1"
  local localversion="$2"

  if [[ ! -f "$outdir/.config" ]]; then
    echo "Missing base config at $outdir/.config" >&2
    return 1
  fi

  _set_kcfg "$outdir/.config" CONFIG_LOCALVERSION "\"${localversion}\""
  _set_kcfg "$outdir/.config" CONFIG_LOCALVERSION_AUTO n

  _apply_fragment "$outdir/.config" "${srcdir}/config.base"
  _apply_fragment "$outdir/.config" "${srcdir}/config.plymouth"

  _disable_kcfg "$outdir/.config" CONFIG_GENERIC_CPU3
  _set_kcfg "$outdir/.config" CONFIG_GENERIC_CPU y
  _disable_kcfg "$outdir/.config" CONFIG_MNATIVE_INTEL
  _disable_kcfg "$outdir/.config" CONFIG_MNATIVE_AMD

  make -C "${srcdir}/linux-${_kernelver}" O="$outdir" olddefconfig
}

prepare() {
  cd "${srcdir}"
  git clone --depth 1 --branch "v${_kernelver}" https://github.com/zen-kernel/zen-kernel.git "linux-${_kernelver}"

  make -C "linux-${_kernelver}" O="${srcdir}/build-generic" x86_64_defconfig

  _configure_kernel "${srcdir}/build-generic" "-mados"
}

build() {
  make -C "${srcdir}/linux-${_kernelver}" O="${srcdir}/build-generic" -j"$(nproc)" LLVM=1 CC=clang bzImage modules
}

_package_kernel() {
  local builddir="$1"
  local pkgname="$2"

  local kernver
  kernver="$(make -s -C "${srcdir}/linux-${_kernelver}" O="$builddir" kernelrelease)"
  local kernelimg="${builddir}/arch/x86/boot/bzImage"

  install -dm755 "${pkgdir}/boot"
  install -dm755 "${pkgdir}/usr/lib/modules/${kernver}"

  install -Dm644 "$kernelimg" "${pkgdir}/boot/vmlinuz-${pkgname}"
  make -C "${srcdir}/linux-${_kernelver}" O="$builddir" INSTALL_MOD_PATH="${pkgdir}" modules_install

  install -Dm644 "${builddir}/System.map" "${pkgdir}/boot/System.map-${pkgname}"
  install -Dm644 "${builddir}/.config" "${pkgdir}/boot/config-${pkgname}"
  printf '%s\n' "$kernver" >"${pkgdir}/usr/lib/modules/${kernver}/kernel"
}

_package_headers() {
  local builddir="$1"

  local kernver
  kernver="$(make -s -C "${srcdir}/linux-${_kernelver}" O="$builddir" kernelrelease)"

  install -dm755 "${pkgdir}/usr/lib/modules/${kernver}"
  install -dm755 "${pkgdir}/usr/src/linux-${kernver}"

  cp -r "${srcdir}/linux-${_kernelver}/include" "${pkgdir}/usr/src/linux-${kernver}/"
  install -dm755 "${pkgdir}/usr/src/linux-${kernver}/arch/x86"
  cp -r "${srcdir}/linux-${_kernelver}/arch/x86/include" "${pkgdir}/usr/src/linux-${kernver}/arch/x86/"
  cp -r "${srcdir}/linux-${_kernelver}/scripts" "${pkgdir}/usr/src/linux-${kernver}/"

  install -Dm644 "${srcdir}/linux-${_kernelver}/Makefile" "${pkgdir}/usr/src/linux-${kernver}/Makefile"
  install -Dm644 "$builddir/.config" "${pkgdir}/usr/src/linux-${kernver}/.config"
  install -Dm644 "$builddir/System.map" "${pkgdir}/usr/src/linux-${kernver}/System.map"

  if [[ -f "$builddir/Module.symvers" ]]; then
    install -Dm644 "$builddir/Module.symvers" "${pkgdir}/usr/src/linux-${kernver}/Module.symvers"
  fi

  ln -s "/usr/src/linux-${kernver}" "${pkgdir}/usr/lib/modules/${kernver}/build"
}

package_linux-mados() {
  pkgdesc="madOS generic zen-based kernel for broad x86_64 compatibility and Plymouth"
  depends=(coreutils kmod)
  optdepends=(
    "linux-firmware: firmware images needed for some hardware"
    "mkinitcpio: initramfs generation"
    "plymouth: boot splash userspace"
  )
  provides=(linux-mados="${pkgver}")
  conflicts=(linux-mados)

  _package_kernel "${srcdir}/build-generic" "linux-mados"
}

package_linux-mados-headers() {
  pkgdesc="Headers for linux-mados"
  provides=(linux-mados-headers="${pkgver}")
  conflicts=(linux-mados-headers)

  _package_headers "${srcdir}/build-generic"
}
