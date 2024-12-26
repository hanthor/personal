#!/usr/bin/env bash

# SCRIPT VERSION
GROUP_SETUP_VER=1
GROUP_SETUP_VER_FILE="/etc/james/dx-groups"
GROUP_SETUP_VER_RAN=$(cat "$GROUP_SETUP_VER_FILE")

# Run script if updated
if [[ -f $GROUP_SETUP_VER_FILE && "$GROUP_SETUP_VER" = "$GROUP_SETUP_VER_RAN" ]]; then
  echo "Group setup has already run. Exiting..."
  exit 0
fi

# Function to append a group entry to /etc/group
append_group() {
  local group_name="$1"
  if ! grep -q "^$group_name:" /etc/group; then
    echo "Appending $group_name to /etc/group"
    grep "^$group_name:" /usr/lib/group | tee -a /etc/group > /dev/null
  fi
}

# Setup Groups
append_group docker
append_group incus-admin
append_group lxd
append_group libvirt

wheelarray=($(getent group wheel | cut -d ":" -f 4 | tr  ',' '\n'))
for user in $wheelarray
do
  usermod -aG docker $user
  usermod -aG incus-admin $user
  usermod -aG lxd $user
  usermod -aG libvirt $user
done

# Prevent future executions
echo "Writing state file"
echo "$GROUP_SETUP_VER" > "$GROUP_SETUP_VER_FILE"