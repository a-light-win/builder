ARG BASE_IMAGE_PATH=ghcr.io/a-light-win/builder
FROM ${BASE_IMAGE_PATH}/debian:12
ARG PLATFORM=linux
ARG ARCH=x86_64
ARG VERSION
COPY zig-${PLATFORM}-${ARCH}-${VERSION}/ /usr/bin/
