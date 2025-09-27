FROM oraclelinux:8.10

# enable EPEL (if not already)
RUN dnf install -y oracle-epel-release-el8 || dnf install -y epel-release \
 && dnf config-manager --enable ol8_codeready_builder
# development tools
RUN dnf groupinstall -y "Development Tools" \
 && dnf install -y \
    git wget python3-pip python3-colcon-common-extensions \
    cmake3 ninja-build openssl-devel libaio-devel zlib-devel \
    libstdc++-static libuuid-devel \
    tinyxml2 tinyxml2-devel \
 && dnf update -y

# choose an install prefix
ARG INSTALL_PREFIX=/opt/fast-dds-3
RUN mkdir -p $INSTALL_PREFIX
# create a build area
RUN mkdir -p ~/fastdds_build && cd ~/fastdds_build

RUN git clone --branch v2.3.1 https://github.com/eProsima/Fast-CDR.git Fast-CDR \
 && git clone --branch v3.3.0 https://github.com/eProsima/Fast-DDS.git Fast-DDS \
 && git clone --branch asio-1-13-0 https://github.com/chriskohlhoff/asio.git asio-repo \
 && git clone --branch v1.3.1 https://github.com/eProsima/foonathan_memory_vendor.git foonathan_memory_vendor

RUN cd foonathan_memory_vendor \
 && mkdir -p build && cd build \
 && cmake3 .. \
  -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -D BUILD_SHARED_LIBS=ON \
  -D CMAKE_BUILD_TYPE=Release \
 && cmake3 --build . --target install -j$(nproc)

# build Fast-CDR
RUN cd Fast-CDR \
 && mkdir build && cd build \
 && cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX .. \
 && cmake3 --build . -- -j$(nproc) \
 && cmake3 --build . --target install \
 && cd .. \
 && cd .. \
 && cp -rf /asio-repo/asio/include/* $INSTALL_PREFIX/include/. \
 && ls $INSTALL_PREFIX/include \
 && cd Fast-DDS \
 && mkdir build && cd build \
 && cmake3 \
    -D FASTRTPS_BUILD_TESTS=OFF \
    -D CMAKE_BUILD_TYPE=Release \
    -D ASIO_INCLUDE_DIR=$INSTALL_PREFIX/include \
    -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -D FASTCDR_DIR=$INSTALL_PREFIX/lib/cmake/Fast-CDR \
    .. \
 && cmake3 --build . -- -j$(nproc) \
 && cmake3 --build . --target install
