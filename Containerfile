ARG BASE_VERSION="${MAJOR_VERSION:-latest}"
ARG BASE_IMAGE="ghcr.io/centos-workstation/achillobator"
ARG CACHE_ID_SUFFIX="personal-latest"

FROM ${BASE_IMAGE}:${BASE_VERSION}
COPY system_files /
ARG IMAGE_NAME="${IMAGE_NAME:-personal}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-hanthor}"
ARG MAJOR_VERSION="${MAJOR_VERSION:-latest}"

COPY build.sh /tmp/build.sh

RUN ln -sf /run /var/run

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    dnf clean all && \
    ostree container commit 

RUN bootc container lint