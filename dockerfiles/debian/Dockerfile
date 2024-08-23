ARG VERSION=12
FROM docker.io/library/debian:${VERSION}
RUN useradd -m -u 1000 builder
# Ensure we can use https
RUN apt-get update && \
  apt-get install -y ca-certificates && \
  apt-get clean
