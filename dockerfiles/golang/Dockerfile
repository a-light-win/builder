# Use the official Golang image as the base image
ARG GO_VERSION
FROM docker.io/library/golang:${GO_VERSION}-trixie

# Install necessary dependencies for eBPF
RUN apt-get update && apt-get install -y \
  clang \
  llvm \
  libelf-dev \
  linux-libc-dev \
  libbpf-dev \
  gcc \
  gcc-aarch64-linux-gnu \
  make \
  iproute2 \
  iputils-ping

RUN cd /usr/include && ln -n -sf ../aarch64-linux-gnu/include aarch64-linux-gnu

# Install protoc for gRPC
RUN apt-get install -y protobuf-compiler
