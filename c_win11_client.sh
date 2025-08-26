#!/bin/bash
##################################################################
# Prerequisites: 
# Base Images(SysPrepped & Read-Only) and stored in:
#    /var/lib/libvirt/images/base/win11-base.qcow2
# Child Images stored in:
#    /var/lib/libvirt/images/
#################################################################

# Naming Variables (used for auto-naming the client)
current_time=$(date +"%H-%M-%S")
client_name="Win11-$current_time"

# Create Windows 11 child disks
# Windows 11 VMs
sudo qemu-img create -f qcow2 -F qcow2 \
  -b /var/lib/libvirt/images/base/win11-base.qcow2 \
  "/var/lib/libvirt/images/$client_name.qcow2"
# Verify Disk
qemu-img info "/var/lib/libvirt/images/$client_name.qcow2"


# Boot child VM with virt-install
sudo virt-install \
  --name "$client_name" \
  --memory 8192 --vcpus 4 --cpu host \
  --machine q35 \
  --os-variant win11 \
  --disk path="/var/lib/libvirt/images/$client_name.qcow2",format=qcow2,bus=sata,cache=none,discard=unmap \
  --disk path="$VIRTIO_ISO",device=cdrom \
  --network network=default,model=virtio \
  --graphics spice \
  --boot uefi \
  --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
  --noautoconsole --import

# Key points
# Never boot from the base image — always use the child.
# The -F qcow2 flag explicitly tells qemu-img the backing file format (safer).
# If you later move the base image, you’ll need to qemu-img rebase the children.




