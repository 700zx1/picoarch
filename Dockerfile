# Containerfile for SF3000 toolchain v0.1 dev environment
FROM debian:bookworm-slim

LABEL maintainer="you@example.com"

# 1. Install basics
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates wget rsync tar file build-essential \
      git pkg-config patch \
      libsdl1.2-dev libasound2-dev && \
    rm -rf /var/lib/apt/lists/*

# 2. Download and build libpng12
RUN wget https://download.sourceforge.net/libpng/libpng-1.2.59.tar.gz && \
    tar -xvzf libpng-1.2.59.tar.gz && \
    cd libpng-1.2.59 && \
    ./configure --host=mips-mti-linux-gnu --prefix=/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/mipsel-buildroot-linux-gnu/sysroot/usr && \
    make && \
    make install && \
    cd .. && \
    rm -rf libpng-1.2.59 libpng-1.2.59.tar.gz

# 2. Download the SF3000 toolchain release
ARG TOOLCHAIN_URL="https://github.com/700zx1/sf3000toolchain/raw/refs/heads/main/mipsel-buildroot-linux-gnu_sdk-buildroot.tar.gz"
RUN mkdir -p /opt && \
    wget -qO /opt/toolchain.tar.gz ${TOOLCHAIN_URL} && \
    tar zxvf /opt/toolchain.tar.gz -C /opt && \
    rm /opt/toolchain.tar.gz

# 3. Relocate the SDK
WORKDIR /opt/mipsel-buildroot-linux-gnu_sdk-buildroot
RUN chmod +x relocate-sdk.sh && ./relocate-sdk.sh

# 4. Export cross-compile environment permanently
ENV TOOLBIN="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin/mips-mti-linux-gnu-" \
    SYSROOT="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/mipsel-buildroot-linux-gnu/sysroot" \
    CROSS_COMPILE="/opt/mipsel-buildroot-linux-gnu_sdk-buildroot/bin/mips-mti-linux-gnu-" \
    CC=${TOOLBIN}gcc \
    CXX=${TOOLBIN}g++ \
    LD=${TOOLBIN}ld \
    AS=${TOOLBIN}as \
    AR=${TOOLBIN}ar \
    RANLIB=${TOOLBIN}ranlib \
    STRIP=${TOOLBIN}strip \
    CFLAGS="-O2 -march=mips32r2" \
    CXXFLAGS="-O2 -march=mips32r2" \
    PATH="${SYSROOT}/bin:$PATH" \
    HOST=mipsel-linux-gnu \
    TARGET=mipsel-linux-gnu

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
