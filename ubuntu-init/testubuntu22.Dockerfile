# syntax=docker/dockerfile:1
# BUILD: docker build -f testubuntu22.Dockerfile -t testubuntu22_app .
# RUN: docker run -it --entrypoint=/bin/bash testubuntu22_app:latest
FROM ubuntu:22.04

# set via arg for visibility only during build
ARG DEBIAN_FRONTEND=noninteractive

# make sudo available
RUN apt-get update
RUN apt-get install -y sudo
RUN apt-get install -y unzip zip kmod

# install tzdata to disable interactive geographic area chooser
RUN TZ=Etc/UTC apt-get -y install tzdata

# add user with sudo privileges
RUN useradd --uid 42 john_wick -m -d /home/john_wick
RUN usermod -aG sudo john_wick

# disable sudo password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# set default user
USER john_wick
WORKDIR /home/john_wick

# copy scripts
COPY scripts/ubuntu-install-tools.sh .
RUN sudo chmod +x ubuntu-install-tools.sh
COPY scripts/ubuntu-versions.zsh .
RUN sudo chmod +x ubuntu-versions.zsh

# run installation script
RUN ./ubuntu-install-tools.sh -t

SHELL ["/bin/bash", "-c"] 

# print versions on image run
CMD source ~/.profile && ./ubuntu-versions.zsh
