#!/bin/bash

# Prereqs (HOST Machine)
sudo apt-get update
sudo apt-get install -y \
  qemu-kvm libvirt-daemon-system virtinst ovmf virt-manager dialog spice-webdavd spice-vdagent

# Add $USER to security group (reboot after) (HOST Machine)
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

# Download ISO's > then move ISO's to /var/lib/libvirt/boot
# Windows ISO: https://www.microsoft.com/en-us/evalcenter
# https://go.microsoft.com/fwlink/?linkid=2293312&clcid=0x409&culture=en-us&country=us
# Windows Virtio: https://fedorapeople.org/groups/virt/virtio-win

# Create ISO's Directory (HOST Machine)
sudo mkdir -p /var/lib/libvirt/images/boot
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/boot
# Uncomment or run manually to change owner and move ISO's from Downloads to ISO Directory
# sudo chown libvirt-qemu:kvm ~/Downloads/*.iso && sudo mv ~/Downlaods/*.iso /var/lib/libvirt/boot/

# Create Variables to ISO Directories (HOST Machine)
WIN11_ISO=/var/lib/libvirt/boot/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso
VIRTIO_ISO=/var/lib/libvirt/boot/virtio-win.iso

# Create Images Directory (HOST Machine)
sudo mkdir -p /var/lib/libvirt/images/base
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/base

# Create Base Images (HOST Machine)
# Windows 11 empty base image (HOST Machine)
sudo qemu-img create -f qcow2 -o preallocation=metadata,lazy_refcounts=on \
  /var/lib/libvirt/images/base/win11-base2.qcow2 80G

# Build the Windows 11 base (HOST Machine)
sudo virt-install \
  --name build-win11-base2 \
  --memory 8192 --vcpus 4 --cpu host \
  --machine q35 \
  --os-variant win11 \
  --graphics spice \
  --boot uefi \
  --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
  --controller type=scsi,model=virtio-scsi \
  --disk path=/var/lib/libvirt/images/base/win11-base2.qcow2,format=qcow2,bus=sata,cache=none,discard=unmap \
  --disk path="$VIRTIO_ISO",device=cdrom \
  --cdrom "$WIN11_ISO" \
  --network network=default,model=virtio \
  --channel unix,target.type=virtio,name=org.qemu.guest_agent.0
 
# Windows 11 Setup (Inside VM-Windows11):
# 1. When disks aren’t visible, click Load driver → browse the VirtIO ISO drive.
# 2. Load Stor driver from vioscsi\w11\amd64 (or viostor\w11\amd64 if using virtio‑blk).
# 3. Proceed with install.
# 4. After first login, from the VirtIO ISO run virtio-win-guest-tools.exe (installs NetKVM, Balloon, QEMU Guest Agent, etc.).
# 5. Apply minimal baseline tweaks/updates you want baked into the gold image.
# 6. Generalize base, Open admin PowerShell and run cmd below (then wait for vm to power off): 
#    C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /mode:vm
#
# Post Windows 11 Setup (HOST Machine)
# (Optional) compact/compress
# sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/base/win11-base.qcow2 \
#  /var/lib/libvirt/images/base/win11-base.comp2.qcow2 && \
 sudo mv /var/lib/libvirt/images/base/win11-base.comp2.qcow2 /var/lib/libvirt/images/base/win11-base.qcow2

# Lock it read-only (HOST Machine)
# sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/base/win11-base.qcow2
# sudo chmod 0444 /var/lib/libvirt/images/base/win11-base.qcow2
# (Optional, extra hardening; root needed to toggle later)
# sudo chattr +i /var/lib/libvirt/images/base/win11-base.qcow2

# NOTES:
# 1. Never boot a VM from the base after you lock it. Always create per‑VM children (backing files) for day‑to‑day use.
# 2. Keep the VirtIO ISO mounted during install so you can load storage + network drivers and install the QEMU Guest Agent.
# 3. If --os-variant isn’t recognized on your distro, query available IDs: osinfo-query os | grep -i windows.
