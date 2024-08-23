ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG PKG_NAME
COPY "${PKG_NAME}.deb" "/tmp/${PKG_NAME}.deb"
RUN apt-get install -y -f "/tmp/${PKG_NAME}.deb"
