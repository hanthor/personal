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

# Update the package repository and set mirror
# dnf update -y --refresh #diabled dies to microcode_ctl causing failures

# Try making DNF faster
function dnf_install() {
  dnf install -y \
  --setopt=fastestmirror=True \
  --setopt=install_weak_deps=False  \
  "$@"
}

####################
# Removals         #
####################

# Remove subscription-manager
dnf remove -y \
subscription-manager \
gnome-extensions-app

####################
# Special Additions#
####################


# VSCODE: Get latest VSCode RPM for x86_64 and install with dnf
VSCODE_REPO_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
VSCODE_RPM_URL=$(curl -sI $VSCODE_REPO_URL | grep -i location | awk '{print $2}' | tr -d '\r')
dnf_install  -y $VSCODE_RPM_URL

# Docker: Install Docker
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf_install -y docker-ce docker-ce-cli containerd.io
dnf config-manager --set-disabled docker-ce-stable


####################
# Install Packages #
####################

#dnf group install -y "Virtualization Host"

# Install the packages
packages=(
  adobe-source-code-pro-fonts
  baobab
  bcc
  bpftrace
  cockpit
  cockpit-bridge
  cockpit-machines
  cockpit-ostree
  cockpit-podman
  cockpit-storaged
  cockpit-ws
  dbus-x11
  firewall-config
  fish
  flatpak-builder
  git-credential-libsecret
  gnome-disk-utility
  google-droid-sans-mono-fonts
  google-noto-*
  golang
  hplip
  ifuse
  krb5-workstation
  libimobiledevice
  libsss_autofs
  libvirt
  libvirt-client-qemu
  libvirt-daemon
  libvirt-daemon-config-nwfilter
  libvirt-devel
  libvirt-nss
  libxcrypt-compat
  lm_sensors
  mesa-libGLU
  numactl
  oddjob-mkhomedir
  osbuild-selinux
  powertop
  pulseaudio-utils
  python3-pip
  samba
  samba-dcerpc
  samba-ldb-ldap-modules
  samba-winbind-clients
  samba-winbind-modules
  setools-console
  speech-dispatcher
  speech-dispatcher-espeak-ng
  speech-dispatcher-utils
  stress-ng
  sysprof
  tmux
  trace-cmd
  udica
  usbmuxd
  virt-v2v
  virt-viewer
  wireguard-tools
  zsh
  
)

dnf_install -y "${packages[@]}"


dnf upgrade -y

# cleanup
dnf remove -y subscription-manager 
dnf clean all

# remove all older versions of the kernel, except the current one
dnf remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)

# Enable and start services for docker, podman, libvrit, and cockpit
systemctl enable cockpit.socket
systemctl enable libvirtd
systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable libvirt-dbus.service

