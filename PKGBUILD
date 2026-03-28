# madOS Kernel - linux-zen with BORE scheduler
# Maintainer: madOS Team

pkgbase=linux-mados-zen
pkgrel=1
pkgver=6.12.1.zen1
pkgdesc="madOS kernel with BORE scheduler - optimized for desktop responsiveness"
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
)
options=(!strip)
source=(
    config
    0001-bore-scheduler.patch::https://github.com/firelzrd/bore-scheduler/archive/refs/heads/master.tar.gz
)
sha256sums=(
    'SKIP'
    'SKIP'
)

prepare() {
    cd ${srcdir}

    # Clone zen-kernel source
    git clone --depth 1 --branch v${pkgver} https://github.com/zen-kernel/zen-kernel.git linux-${pkgver}

    cd linux-${pkgver}

    # Apply BORE scheduler patch
    if [ -f "${srcdir}/0001-bore-scheduler.patch" ]; then
        msg2 "Applying BORE scheduler patch..."
        patch -p1 -i "${srcdir}/0001-bore-scheduler.patch"
    fi

    # Apply custom config
    cp "${srcdir}/config" .config

    # Set localversion
    sed -i "s|CONFIG_LOCALVERSION=.*|CONFIG_LOCALVERSION=\"-mados-zen\"|g" .config
    sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|g" .config

    # Make olddefconfig to ensure all options are resolved
    make olddefconfig
}

build() {
    cd linux-${pkgver}
    make -j$(nproc) LLVM=0 CC=gcc AS=as zstd
}

package_linux-mados-zen() {
    pkgdesc="madOS kernel with BORE scheduler - optimized for desktop responsiveness"
    depends=(coreutils kmod initramfs)
    optdepends=("linux-firmware: firmware images needed for some hardware")
    provides=(linux-mados-zen=${pkgver})
    conflicts=(linux-mados-zen)

    cd linux-${pkgver}
    local kernver="$(make -s kernelrelease)"
    local kernelimg="${srcdir}/linux-${pkgver}/arch/x86/boot/bzImage"

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

    # Install firmware
    if [ -d firmware ]; then
        make INSTALL_FW_PATH="${pkgdir}/usr/lib/firmware" firmware_install
    fi

    # Create kernel release file
    echo "${kernver}" > ${pkgdir}/usr/lib/modules/${kernver}/kernel
}
