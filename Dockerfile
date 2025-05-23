# Containerfile for SF3000 toolchain v0.1 dev environment
FROM debian:bookworm-slim

LABEL maintainer="you@example.com"

# 1. Install basics
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates wget rsync tar file build-essential \
      git pkg-config patch \
      libsdl1.2-dev libasound2-dev libncurses-dev && \
    rm -rf /var/lib/apt/lists/*

# 2. Download and extract the SF3000 toolchain release
ARG TOOLCHAIN_URL="https://github.com/700zx1/sf3000toolchain/raw/refs/heads/main/mipsel-buildroot-linux-gnu_sdk-buildroot.tar.gz"
RUN mkdir -p /opt && \
    wget -qO /opt/toolchain.tar.gz ${TOOLCHAIN_URL} && \
    ls -lh /opt/toolchain.tar.gz && \
    file /opt/toolchain.tar.gz && \
    tar zxvf /opt/toolchain.tar.gz -C /opt && \
    rm /opt/toolchain.tar.gz

# 3. Relocate the SDK
WORKDIR /opt/mipsel-buildroot-linux-gnu_sdk-buildroot
RUN chmod +x relocate-sdk.sh && ./relocate-sdk.sh

# 4. Export cross-compile environment permanently
ENV TOOLBIN="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin/mips-mti-linux-gnu-" \
    SYSROOT="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/mipsel-buildroot-linux-gnu/sysroot" \
    CROSS_COMPILE="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin/mips-mti-linux-gnu-" \
    CC="${TOOLBIN}gcc" \
    CXX="${TOOLBIN}g++" \
    LD="${TOOLBIN}ld" \
    AS="${TOOLBIN}as" \
    AR="${TOOLBIN}ar" \
    RANLIB="${TOOLBIN}ranlib" \
    STRIP="${TOOLBIN}strip" \
    CFLAGS="-O2 -march=mips32r2" \
    CXXFLAGS="-O2 -march=mips32r2" \
    PATH="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin:${PATH}"


# Add Linux kernel headers build steps
WORKDIR /build
RUN wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.1.tar.xz && \
    tar -xvJf linux-5.10.1.tar.xz && \
    cd linux-5.10.1 && \
    make ARCH=mips CROSS_COMPILE=mips-mti-linux-gnu- headers_install INSTALL_HDR_PATH=/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/mipsel-buildroot-linux-gnu/sysroot/usr && \
    cd .. && \
    rm -rf linux-5.10.1 linux-5.10.1.tar.xz

# Check if the toolchain is working and the sysroot is set up correctly
RUN echo "Checking linux/random.h..." && \
    ls /opt/mipsel-buildroot-linux-gnu_sdk-buildroot/mipsel-buildroot-linux-gnu/sysroot/usr/include/linux/random.h

# 5. Download and build libpng12 using the cross-compiler
WORKDIR /build
RUN wget https://download.sourceforge.net/libpng/libpng-1.2.59.tar.gz && \
    tar -xvzf libpng-1.2.59.tar.gz && \
    cd libpng-1.2.59 && \
    PATH="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin:$PATH" \
    CC=mips-mti-linux-gnu-gcc \
    AR=mips-mti-linux-gnu-ar \
    RANLIB=mips-mti-linux-gnu-ranlib \
    ./configure --host=mips-mti-linux-gnu --prefix=/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/mipsel-buildroot-linux-gnu/sysroot/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf libpng-1.2.59 libpng-1.2.59.tar.gz

# 6. Cleanup build directory
WORKDIR /
RUN rm -rf /build

# Add BusyBox build steps
WORKDIR /build
RUN wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2 && \
    tar -xvjf busybox-1.36.1.tar.bz2 && \
    cd busybox-1.36.1 && \
    PATH="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin:$PATH" \
    make defconfig && \
    sed -i 's/CONFIG_SEEDRNG=y/# CONFIG_SEEDRNG is not set/' .config && \
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config && \
    PATH="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin:$PATH" \
    CROSS_COMPILE=mips-mti-linux-gnu- \
    make -j$(nproc) && \
    make install && \
    cd ..
    #rm -rf busybox-1.36.1 busybox-1.36.1.tar.bz2

# Cleanup build directory
#WORKDIR /
#RUN rm -rf /build

# 4a. Add the real toolchain `bin/` to your PATH
#ENV PATH="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin:${PATH}"

# 4b. Symlink the *real* cross-compiler binaries into /usr/bin
RUN ln -s ${TOOLBIN}gcc /usr/bin/mips-linux-gnu-gcc \
 && ln -s ${TOOLBIN}g++ /usr/bin/mips-linux-gnu-g++ \
 && ln -s ${TOOLBIN}ld  /usr/bin/mips-linux-gnu-ld \
 && ln -s ${TOOLBIN}as  /usr/bin/mips-linux-gnu-as \
 && ln -s ${TOOLBIN}ar  /usr/bin/mips-linux-gnu-ar \
 && ln -s ${TOOLBIN}ranlib /usr/bin/mips-linux-gnu-ranlib \
 && ln -s ${TOOLBIN}strip /usr/bin/mips-linux-gnu-strip

# 5. Switch to a workspace directory (mounted from host)
WORKDIR /workspace
VOLUME /workspace

# Default to an interactive shell
CMD ["bash"]
