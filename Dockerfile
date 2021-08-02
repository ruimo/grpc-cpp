FROM ubuntu
MAINTAINER Shisei Hanai<ruimo.uno@gmail.com>

ENV GRPC_DIR /opt/grpc
ENV PATH $GRPC_DIR/bin:$PATH

RUN \
  apt-get update -y && \
  apt-get install locales tzdata iputils-ping net-tools -y

RUN locale-gen ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV TZ=Asia/Tokyo 

RUN \
  apt-get install -y git wget build-essential autoconf libtool pkg-config

RUN mkdir -p $GRPC_DIR
RUN \
  wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh && \
  sh cmake-linux.sh -- --skip-license --prefix=$GRPC_DIR && \
  rm cmake-linux.sh

CMD /bin/bash
