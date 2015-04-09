FROM ubuntu:14.04
MAINTAINER Matthew Hook <hookenz@gmail.com>

# Setup environment
RUN apt-get -y update && apt-get -y install \
      wget git make dpkg-dev && \
    mkdir -p /usr/src/kernels && \
    mkdir -p /opt/nvidia && \
    apt-get autoremove && apt-get clean

# Downloading early so we fail early if we can't get the key ingredient
RUN wget -P /opt/nvidia http://us.download.nvidia.com/XFree86/Linux-x86_64/346.47/NVIDIA-Linux-x86_64-346.47.run

# Download kernel source and prepare modules
WORKDIR /usr/src/kernels
RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git linux
WORKDIR linux
RUN git checkout -b stable v`uname -r` && zcat /proc/config.gz > .config && make modules_prepare
RUN sed -i -e "s/`uname -r`+/`uname -r`/" include/generated/utsrelease.h # In case a '+' was added

# Nvidia drivers setup
WORKDIR /opt/nvidia
RUN echo "./NVIDIA-Linux-x86_64-346.47.run -q -a -n -s --kernel-source-path=/usr/src/kernels/linux/ && modprobe nvidia" >> install_kernel_module && \
    chmod +x install_kernel_module

CMD ["/opt/nvidia/install_kernel_module"]
