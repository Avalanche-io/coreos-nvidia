FROM ubuntu:14.04
MAINTAINER Joshua Kolden <joshua@studiopyxis.com>

# Setup environment
RUN apt-get -y update && apt-get -y install git make dpkg-dev && mkdir -p /usr/src/kernels && mkdir -p /opt/nvidia/nvidia_installers

# Downloading early so we fail early if we can't get the key ingredient
ADD http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_7.0.28_linux.run

# Download kernel source and prepare modules
WORKDIR /usr/src/kernels
RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git linux
WORKDIR linux
RUN git checkout -b stable v`uname -r` && zcat /proc/config.gz > .config && make modules_prepare
RUN sed -i -e "s/`uname -r`+/`uname -r`/" include/generated/utsrelease.h # In case a '+' was added

# Nvidia drivers setup
WORKDIR /opt/nvidia/
RUN chmod +x cuda_7.0.28_linux.run && ./cuda_7.0.28_linux.run -extract=`pwd`/nvidia_installers
WORKDIR nvidia_installers
RUN echo "NVIDIA-Linux-x86_64-346.46.run -q -a -n -s --kernel-source-path=/usr/src/kernels/linux/ && modprobe nvidia" > install_nvidia_kernal_module
RUN chmod +x install_nvidia_kernal_module
CMD ["sh", "-c", "/opt/nvidia/nvidia_installers/install_nvidia_kernal_module"]
