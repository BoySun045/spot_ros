
FROM ubuntu:20.04
# FROM nvidia/cuda:11.5.0-cudnn8-runtime-ubuntu18.04

RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list
ARG DEBIAN_FRONTEND=noninteractive

#######################################################################
##                    install essential packages                     ##
#######################################################################


RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    apt-utils \
    python3-pip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    zip \
    unzip \
	g++ \
	perl \
    wget \
    git \
    nautilus\
    net-tools \
    gedit \
    curl

RUN python3 -m pip install --upgrade pip
RUN apt-get update && apt-get install  -y python3-ruamel.yaml


#######################################################################
##                            install ros                            ##
#######################################################################

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
# setup keys
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt-get update && apt-get install -y \
    python3-rosinstall \
    python3-rosdep \
    python3-vcstools

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init
RUN rosdep update

# install ros packages
ENV ROS_DISTRO noetic


# install bootstrap tools
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-desktop-full

# setup entrypoint
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
 

#######################################################################
##                   install additional ros package                  ##
#######################################################################
RUN apt-get update && apt-get install -y \
    ros-noetic-checkerboard-detector

#######################################################################
##                   install spot api                                ##
#######################################################################
RUN pip3 install bosdyn-client bosdyn-mission bosdyn-api bosdyn-core

#######################################################################
##                            cleaning up                            ##
#######################################################################

RUN  rm -rf /var/lib/apt/lists/*

#######################################################################
##                         catkin setting                            ##
#######################################################################


RUN sudo apt update
RUN sudo sudo apt install -y \
    python3-catkin-tools \
    python3-osrf-pycommon

#init catkin_ws
RUN mkdir -p /catkin_ws/src 
COPY ./ /catkin_ws/src/spot_ros
RUN cd /catkin_ws/src && \
   /bin/bash -c 'source /opt/ros/noetic/setup.bash;'

# RUN cd /catkin_ws/src && \
#     git clone https://github.com/heuristicus/spot_ros.git -b master && \
#     cd spot_ros && \
#     git checkout bb82c29e9d51d12d57d53c8b4d4faecb600a1bc8

WORKDIR /catkin_ws
RUN /bin/bash -c ' . /opt/ros/noetic/setup.bash && catkin init  && catkin build' 

RUN cd /catkin_ws && \
    /bin/bash -c 'source devel/setup.bash;'

# RUN echo "source /catkin_ws/devel/setup.bash" >> ~/.bashrc



#######################################################################
##                           ros settings                            ##
#######################################################################

# RUN echo "export PS1='\[\e[1;31;40m\]AzureKinect\[\e[0m\] \u:\w\$ '">> ~/.bashrc
