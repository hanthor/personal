#!/bin/bash

set -ouex pipefail

# Image Info
OLD_PRETTY_NAME=$(bash -c 'source /usr/lib/os-release ; echo $NAME $VERSION')
MAJOR_VERSION=$(bash -c 'source /usr/lib/os-release ; echo $VERSION_ID')
IMAGE_PRETTY_NAME="James' Personal OS"
IMAGE_LIKE="rhel fedora"
HOME_URL="https://projectbluefin.io"
DOCUMENTATION_URL="https://docs.projectbluefin.io"
SUPPORT_URL="https://github.com/hanthor/personal/issues/"
BUG_SUPPORT_URL="https://github.com/hanthor/personal/issues/"
CODE_NAME="hanthorOS"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

image_flavor="main"
cat > $IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$image_flavor",
  "image-vendor": "$IMAGE_VENDOR",
  "image-tag": "$MAJOR_VERSION",
  "centos-version": "$MAJOR_VERSION"
}
EOF

# OS Release File (changed in order with upstream)
sed -i "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" /usr/lib/os-release
sed -i "s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"$CODE_NAME\"|" /usr/lib/os-release
sed -i "s/^ID=centos/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" /usr/lib/os-release
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} $MAJOR_VERSION (FROM $OLD_PRETTY_NAME)\"/" /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
echo "DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"" | tee -a /usr/lib/os-release
echo "SUPPORT_URL=\"$SUPPORT_URL\"" | tee -a /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:centos:centos|CPE_NAME=\"cpe:/o:universal-blue:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
echo "DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,,}\"" | tee -a /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release

if [[ -n "${SHA_HEAD_SHORT:-}" ]]; then
  echo "BUILD_ID=\"$SHA_HEAD_SHORT\"" >> /usr/lib/os-release
fi

# Fix issues caused by ID no longer being rhel??? (FIXME: check if this is necessary)
sed -i "s/^EFIDIR=.*/EFIDIR=\"rhel\"/" /usr/sbin/grub2-switch-to-blscfg

# Update the package repository
dnf update -y

# Removals

# Remove subscription-manager
dnf remove -y subscription-manager 


# Special Additions

# ZFS
dnf install -y https://zfsonlinux.org/epel/zfs-release-2-3$(rpm --eval "%{dist}").noarch.rpm

# VSCODE: Get latest VSCode RPM for x86_64 and install with dnf
VSCODE_REPO_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
VSCODE_RPM_URL=$(curl -sI $VSCODE_REPO_URL | grep -i location | awk '{print $2}' | tr -d '\r')
dnf install -y $VSCODE_RPM_URL

# Docker: Install Docker
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io


dnf group install -y --nobest "Virtualization Host"

# Install the packages
packages=(
    gnome-disk-utility
    baobab
    speech-dispatcher-espeak-ng
    speech-dispatcher-utils
    speech-dispatcher
    adobe-source-code-pro-fonts
    bcc
    bpftrace
    dbus-x11
    flatpak-builder
    firewall-config
    google-droid-sans-mono-fonts
    libvirt-nss
    numactl
    osbuild-selinux
    powertop
    sysprof
    trace-cmd
    udica
    virt-manager
    virt-v2v
    virt-viewer
    cockpit
    cockpit-storaged 
    cockpit-bridge 
    cockpit-ws 
    cockpit-machines 
    cockpit-ostree 
    cockpit-podman 
    systemd-container
    fish
    firewall-config
    git-credential-libsecret
    hplip
    krb5-workstation
    ifuse
    libimobiledevice
    libxcrypt-compat
    libsss_autofs
    lm_sensors
    mesa-libGLU
    oddjob-mkhomedir
    pulseaudio-utils
    python3-pip
    samba-dcerpc
    samba-ldb-ldap-modules
    samba-winbind-clients
    samba-winbind-modules
    samba
    setools-console
    stress-ng
    tmux
    usbmuxd
    wireguard-tools
    zsh
)

dnf install -y "${packages[@]}"


dnf upgrade -y

# Enable and start services for docekr, podman, libvrit, and cockpit
systemctl enable cockpit.socket
systemctl enable libvirtd
systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable libvirt-dbus.service
systemctl enable dx-groups.service


# Remove subscription-manager

dnf remove -y subscription-manager 

