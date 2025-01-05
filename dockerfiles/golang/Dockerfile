# Use the official Golang image as the base image
FROM docker.io/library/golang:1.23.4-bookworm

# Install necessary dependencies for eBPF
RUN apt-get update && apt-get install -y \
  clang \
  llvm \
  libelf-dev \
  linux-libc-dev \
  libbpf-dev \
  gcc \
  make \
  iproute2 \
  iputils-ping

# Install protoc for gRPC
RUN apt-get install -y protobuf-compiler
