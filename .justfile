# Create a centos-stream9 vm using virt-install and the qcow2 in output/qcow/disk.qcow2
# This is a simple example, and you may need to adjust the parameters to suit your needs.
# You may also need to adjust the --network parameter to suit your environment.
add-vm:
  if [ ! -f output/qcow/disk.qcow2 ]; then
    just build-vm
  fi
  virt-install \
    --name personal$(date +%Y%m%d) \
    --memory 8192 \
    --vcpus 8 \
    --disk path=output/qcow/disk.qcow2,format=qcow2 \
    --os-variant centos-stream9 \
    --network network=default \
    --graphics none \
    --console pty,target_type=serial \
    --location http://mirror.centos.org/centos/10-stream/BaseOS/x86_64/os/ \
    --extra-args 'console=ttyS0,115200n8 serial' \
    --wait 0