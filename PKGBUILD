# madOS Kernel - linux-zen with BORE scheduler
# Maintainer: madOS Team

pkgbase=linux-mados-zen
pkgrel=1
_pkgver=6.12.1.zen1
pkgver=${_pkgver}
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
)
options=(!strip)
source=(
    config
    0001-bore-scheduler.patch
)
sha256sums=(
    'SKIP'
    'SKIP'
)

_kernelver=${pkgver}
_extrapatches=()

prepare() {
    cd ${srcdir}

    # Clean previous builds
    rm -rf build-${pkgver} 2>/dev/null || true

    # Create build directory
    mkdir -p build-${pkgver}
    cd build-${pkgver}

    # The source will be downloaded by makepkg internally from the _kernelver
    # We use the Arch Linux ABS system to get the kernel source

    msg2 "Setting up kernel source..."

    # In a proper build environment, this would fetch from kernel.org
    # For now, we assume the source is available or will be fetched
}

build() {
    cd ${srcdir}/build-${pkgver}

    # Copy our custom config
    cp ${srcdir}/config .config

    # Set localversion
    sed -i "s|CONFIG_LOCALVERSION=.*|CONFIG_LOCALVERSION=\"-mados-zen\"|g" .config
    sed -i "s|CONFIG_LOCALVERSION_AUTO=.*|CONFIG_LOCALVERSION_AUTO=n|g" .config

    # Apply BORE patch
    if [ -f "${srcdir}/0001-bore-scheduler.patch" ]; then
        msg2 "Applying BORE scheduler patch..."
        patch -p1 -i "${srcdir}/0001-bore-scheduler.patch"
    fi

    # Make olddefconfig to ensure all options are resolved
    make olddefconfig

    # Build with zstd compression
    make -j$(nproc) LLVM=0 CC=gcc AS=as zstd
}

package_linux-mados-zen() {
    pkgdesc="madOS kernel with BORE scheduler - optimized for desktop responsiveness"
    depends=(coreutils kmod initramfs)
    optdepends=("linux-firmware: firmware images needed for some hardware")
    provides=(linux-mados-zen=${pkgver})
    conflicts=(linux-mados-zen)
    replaces=(linux-zen)

    cd ${srcdir}/build-${pkgver}
    local kernver="$(make -s kernelrelease)"
    local kernelimg="${srcdir}/build-${pkgver}/arch/x86/boot/bzImage"

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

    # Install firmware (if available)
    if [ -d ${srcdir}/build-${pkgver}/firmware ]; then
        make INSTALL_FW_PATH="${pkgdir}/usr/lib/firmware" firmware_install
    fi

    # Create kernel release file
    echo "${kernver}" > ${pkgdir}/usr/lib/modules/${kernver}/kernel
}

# vim: set ts=4 sts=4 sw=4 et:
