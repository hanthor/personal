FROM ghcr.io/centos-workstation/achillobator:latest
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
