# madOS Kernel - linux-zen optimized
# Maintainer: madOS Team

pkgbase=linux-mados-zen
pkgrel=1
pkgver=6.19.10.zen1-1
_kernelver=6.19.10-zen1
pkgdesc="madOS kernel optimized for desktop responsiveness with NVMe + Btrfs support"
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
    config
)
sha256sums=(
    'SKIP'
)

prepare() {
    cd ${srcdir}

    # Clone zen-kernel source
    git clone --depth 1 --branch v${_kernelver} https://github.com/zen-kernel/zen-kernel.git linux-${_kernelver}

    cd linux-${_kernelver}

    # Apply custom config
    cp "${srcdir}/config" .config

    # Set localversion
    sed -i "s|CONFIG_LOCALVERSION=.*|CONFIG_LOCALVERSION=\"-mados-zen\"|g" .config
    sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|g" .config

    # Make olddefconfig to ensure all options are resolved
    yes | make olddefconfig 2>/dev/null || true
}

build() {
    cd linux-${_kernelver}
    make -j$(nproc) LLVM=1 CC=clang bzImage
}

package_linux-mados-zen() {
    pkgdesc="madOS kernel optimized for desktop responsiveness with NVMe + Btrfs support"
    depends=(coreutils kmod initramfs)
    optdepends=("linux-firmware: firmware images needed for some hardware")
    provides=(linux-mados-zen=${pkgver})
    conflicts=(linux-mados-zen)

    cd linux-${_kernelver}
    local kernver="$(make -s kernelrelease)"
    local kernelimg="${srcdir}/linux-${_kernelver}/arch/x86/boot/bzImage"

    # Create destination directories
    install -dm755 ${pkgdir}/boot
    install -dm755 ${pkgdir}/usr/lib/modules/${kernver}

    # Install kernel image
    install -Dm644 ${kernelimg} ${pkgdir}/boot/vmlinuz-linux-mados-zen

    # Install modules
    make INSTALL_MOD_PATH="${pkgdir}" modules_install

    # Install System.map and config
    install -Dm644 System.map ${pkgdir}/boot/System.map-linux-mados-zen
    install -Dm644 .config ${pkgdir}/boot/config-linux-mados-zen

    # Create kernel release file
    echo "${kernver}" > ${pkgdir}/usr/lib/modules/${kernver}/kernel
}

package_linux-mados-zen-headers() {
    pkgdesc="madOS kernel headers for compiling external modules"
    depends=()
    provides=(linux-mados-zen-headers=${pkgver})
    conflicts=(linux-mados-zen-headers)

    cd linux-${_kernelver}
    local kernver="$(make -s kernelrelease)"

    # Create destination directories
    install -dm755 ${pkgdir}/usr/lib/modules/${kernver}
    install -dm755 ${pkgdir}/usr/src/

    # Copy headers source tree
    cp -r ${srcdir}/linux-${_kernelver}/include ${pkgdir}/usr/src/linux-${kernver}/
    cp -r ${srcdir}/linux-${_kernelver}/arch/x86/include ${pkgdir}/usr/src/linux-${kernver}/arch/x86/
    cp -r ${srcdir}/linux-${_kernelver}/scripts ${pkgdir}/usr/src/linux-${kernver}/

    # Copy build files
    cp ${srcdir}/linux-${_kernelver}/Makefile ${pkgdir}/usr/src/linux-${kernver}/ 2>/dev/null || true
    cp ${srcdir}/linux-${_kernelver}/Module.symvers ${pkgdir}/usr/src/linux-${kernver}/ 2>/dev/null || true

    # Install generated headers and config
    install -Dm644 .config ${pkgdir}/usr/src/linux-${kernver}/.config
    install -Dm644 System.map ${pkgdir}/usr/src/linux-${kernver}/System.map

    # Create build symlink for kernel module compilation
    ln -s /usr/src/linux-${kernver} ${pkgdir}/usr/lib/modules/${kernver}/build
}
