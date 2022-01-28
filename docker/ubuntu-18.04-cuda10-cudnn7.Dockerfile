FROM ubuntu:18.04@sha256:fc0d6af5ab38dab33aa53643c4c4b312c6cd1f044c1a2229b2743b252b9689fc
LABEL maintainer="Howard O'Neil"

ARG CUDA_VERSION=10.0.130
ARG CUDNN_VERSION=7.6.5
ARG OS_VERSION=18.04
ARG OS_ARCH=amd64

# Install requried libraries
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    wget \
    zlib1g-dev \
    git \
    pkg-config \
    sudo \
    ssh \
    gcc \
    vim \
    libssl-dev \
    pbzip2 \
    pv \
    bzip2 \
    unzip \
    devscripts \
    lintian \
    fakeroot \
    dh-make \
    build-essential

# Install python3
RUN apt-get install -y --no-install-recommends \
      python3 \
      python3-pip \
      python3-dev \
      python3-wheel &&\
    cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    ln -s /usr/bin/pip3 pip;

COPY .bashrc /
WORKDIR /

RUN cat .bashrc > ~/.bashrc
RUN rm -f .bashrc

# Set environment + workdir
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH=/usr/local/cuda/bin:$PATH

# CUDA 64 bit libs
# ALso the first LD_LIBRARY_PATH value
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64

COPY download/cuda_10.2.1_linux.run /
COPY install-cuda10.0.0-cudnn7.6.5.sh /
COPY download/libcudnn7_7.6.5.32-1+cuda10.0_amd64.deb /
COPY download/libcudnn7-dev_7.6.5.32-1+cuda10.0_amd64.deb /
COPY download/libcudnn7-doc_7.6.5.32-1+cuda10.0_amd64.deb /

WORKDIR /

RUN chmod +x /install-cuda10.0.0-cudnn7.6.5.sh

# blacklist nouveau
RUN mkdir -p /etc/modprobe.d && touch /etc/modprobe.d/blacklist-nouveau.conf
RUN echo "blacklist nouveau" >> /etc/modprobe.d/blacklist-nouveau.conf
RUN echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf

# Regenerate the kernel initramfs
RUN apt-get install -y initramfs-tools
RUN update-initramfs -u