#Docker file to build nvidia drivers for an Ubuntu container in CoreOS
#Container must be run in privileged mode
#eg. > docker run --privileged=true sutdiopyxis/coreos-nvidia
FROM ubuntu:14.04
MAINTAINER Joshua Kolden <joshua@studiopyxis.com>

# Setup environment
RUN apt-get -y update && apt-get -y install git make dpkg-dev && mkdir -p /usr/src/kernels && mkdir -p /opt/nvidia/nvidia_installers

# Downloading early so we fail early if we can't get the key ingredient
ADD http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run /opt/nvidia/

# Download kernel source and prepare modules
WORKDIR /usr/src/kernels
RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git linux
WORKDIR linux
RUN git checkout -b stable v`uname -r` && zcat /proc/config.gz > .config && make modules_prepare
RUN sed -i -e "s/`uname -r`+/`uname -r`/" include/generated/utsrelease.h # In case a '+' was added

# Nvidia drivers setup
WORKDIR /opt/nvidia/
RUN chmod +x cuda_6.5.14_linux_64.run && ./cuda_6.5.14_linux_64.run -extract=`pwd`/nvidia_installers
WORKDIR nvidia_installers
RUN echo "./NVIDIA-Linux-x86_64-340.29.run -q -a -n -s --kernel-source-path=/usr/src/kernels/linux/ && modprobe nvidia" > install_nvidia_kernal_module
RUN chmod +x install_nvidia_kernal_module
CMD ["sh", "-c", "/opt/nvidia/nvidia_installers/install_nvidia_kernal_module"]

# run `lsmod | grep -i nvidia` in CoreOS to confirm driver is installed.
