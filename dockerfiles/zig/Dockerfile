FROM docker.io/library/debian:12
ARG PLATFORM=linux
ARG ARCH=x86_64
ARG VERSION
COPY zig-${PLATFORM}-${ARCH}-${VERSION}/ /usr/bin/
# Ensure zig can download files via https
RUN apt-get update && \
  apt-get install -y ca-certificates && \
  apt-get clean
