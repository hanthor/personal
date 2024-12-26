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
    ($GUM_CHOOSE_SELECTED_BACKGROUND)
    Color
    Background
    --selected.background=""
    ($GUM_CHOOSE_SELECTED_FOREGROUND)
    Color
    Foreground
    --selected.foreground="212"
    ($GUM_CHOOSE_ITEM_BACKGROUND)
    Color
    Background
    --item.background=""
    ($GUM_CHOOSE_ITEM_FOREGROUND)
    Color
    Foreground
    --item.foreground=""
    ($GUM_CHOOSE_HEADER_BACKGROUND)
    Color
    Background
    --header.background=""
    ($GUM_CHOOSE_HEADER_FOREGROUND)
    Color
    Foreground
    --header.foreground="99"
    ($GUM_CHOOSE_CURSOR_BACKGROUND)
    Color
    Background
    --cursor.background=""
    ($GUM_CHOOSE_CURSOR_FOREGROUND)
    Color
    Foreground
    --cursor.foreground="212"
    Flags
    Style
    one
    only
    is
    there
    if
    option
    given
    the
    Select
    --select-if-one
    limit)
    (ignores
    options
    of
    number
    unlimited
    Pick
    --no-limit
    pick
    to
    options
    of
    number
    Maximum
    --limit=1
    Selection
    ($GUM_CCHOOSE_TIMEOUT)
    element
    selected
    returns
    choose
    until
    Timeout
    --timeout=0
    ($GUM_CHOOSE_SELECTED)
    selected
    as
    start
    should
    that
    Options
    --selected=,...
    ($GUM_CHOOSE_UNSELECTED_PREFIX)
    1)
    is
    limit
    if
    (hidden
    items
    unselected
    on
    show
    to
    Prefix
    "
    --unselected-prefix="•
    ($GUM_CHOOSE_SELECTED_PREFIX)
    1)
    is
    limit
    if
    (hidden
    items
    selected
    on
    show
    to
    Prefix
    "
    --selected-prefix="✓
    ($GUM_CHOOSE_CURSOR_PREFIX)
    1)
    is
    limit
    if
    (hidden
    item
    cursor
    the
    on
    show
    to
    Prefix
    "
    --cursor-prefix="•
    ($GUM_CHOOSE_HEADER)
    value
    Header
    --header="Choose:"
    ($GUM_CHOOSE_SHOW_HELP)
    keybinds
    help
    Show
    --[no-]show-help
    ($GUM_CHOOSE_CURSOR)
    position
    cursor
    the
    to
    corresponds
    that
    item
    on
    show
    to
    Prefix
    "
    --cursor=">
    ($GUM_CHOOSE_HEIGHT)
    list
    the
    of
    Height
    --height=0
    ($GUM_CHOOSE_ORDERED)
    options
    selected
    the
    of
    order
    the
    Maintain
    --ordered
    number
    version
    the
    Print
    --version
    -v,
    help.
    context-sensitive
    Show
    --help
    -h,
    Flags:
    from.
    choose
    to
    Options
    ...]
    [<options>
    Arguments:
    choices
    of
    list
    a
    from
    option
    an
    Choose
    [flags]
    ...]
    [<options>
    choose
    gum
    Usage:
    gnome-disk-utility.x86_64
    baobab.x86_64
    baobab.x86_64
    speech-dispatcher-espeak-ng.x86_64
    speech-dispatcher-utils.x86_64
    speech-dispatcher.x86_64
    speech-dispatcher-espeak-ng.x86_64
    speech-dispatcher-utils.x86_64
    speech-dispatcher.x86_64
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

