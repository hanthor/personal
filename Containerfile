FROM ghcr.io/centos-workstation/achillobator:latest

RUN dnf install -y https://packages.microsoft.com/yumrepos/vscode/Packages/c/code-1.96.2-1734607808.el8.x86_64.rpm

COPY build.sh /tmp/build.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
