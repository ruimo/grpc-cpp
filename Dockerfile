FROM ubuntu
MAINTAINER Shisei Hanai<ruimo.uno@gmail.com>

ENV GRPC_DIR /opt/grpc
ENV PATH $GRPC_DIR/bin:$PATH

RUN \
  apt-get update -y && \
  apt-get install locales tzdata iputils-ping net-tools apt-transport-https ca-certificates curl gnupg lsb-release -y

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN \
  apt-get update -y && \
  apt-get install docker-ce docker-ce-cli containerd.io -y

RUN \
  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh && \
  bx plugin install container-registry

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

RUN \
  git clone --recurse-submodules -b v1.38.0 https://github.com/grpc/grpc && \
  cd grpc && \
  mkdir -p cmake/build && \
  cd cmake/build && \
  cmake -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=$GRPC_DIR \
      ../.. && \
  make -j 1 && \
  make install && \
  cd ../.. && \
  mkdir -p third_party/abseil-cpp/cmake/build && \
  cd third_party/abseil-cpp/cmake/build && \
  cmake -DCMAKE_INSTALL_PREFIX=$GRPC_DIR \
      -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE \
      ../.. && \
  make -j 1 && \
  make install

CMD /bin/bash
