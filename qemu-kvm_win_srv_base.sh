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
# Windows Virtio: https://fedorapeople.org/groups/virt/virtio-win

# Create ISO's Directory (HOST Machine)
sudo mkdir -p /var/lib/libvirt/images/boot
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/boot
# Uncomment or run manually to change owner and move ISO's from Downloads to ISO Directory
# sudo chown libvirt-qemu:kvm ~/Downloads/*.iso && sudo mv ~/Downlaods/*.iso /var/lib/libvirt/boot/

# Create Variables to ISO Directories (HOST Machine)
WINSRV_ISO=/var/lib/libvirt/boot/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso
VIRTIO_ISO=/var/lib/libvirt/boot/virtio-win.iso

# Create Images Directory (HOST Machine)
sudo mkdir -p /var/lib/libvirt/images/base
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/base

# Windows Server empty base image (HOST Machine)
sudo qemu-img create -f qcow2 -o preallocation=metadata,lazy_refcounts=on \
  /var/lib/libvirt/images/base/winsrv-base.qcow2 80G

# Build the Windows Server base (HOST Machine)
sudo virt-install \
  --name build-winsrv-base \
  --memory 8192 --vcpus 4 --cpu host \
  --machine q35 \
  --os-variant win2k22 \
  --graphics spice \
  --boot uefi \
  --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
  --controller type=scsi,model=virtio-scsi \
  --disk path=/var/lib/libvirt/images/base/winsrv-base.qcow2,format=qcow2,bus=sata,cache=none,discard=unmap \
  --disk path=$VIRTIO_ISO,device=cdrom \
  --cdrom $WINSRV_ISO \
  --network network=default,model=virtio \
  --channel unix,target.type=virtio,name=org.qemu.guest_agent.0


# Windows 11 Server Setup (Inside VM-WindowsServer):
# 1. Load driver from VirtIO ISO: vioscsi\2k22\amd64 (or 2k19/2k25 to match your Server version).
# 2. Finish install, log in, install virtio-win-guest-tools.exe.
# 3. Apply any minimal base settings/updates you want across all children.
# 4. Sysprep, Open admin PowerShell and run cmd below (power off after):
#    C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /mode:vm

# Post Windows Server Setup (HOST Machine)
# (Optional) compact/compress
# sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/base/win11-base.qcow2 \
#  /var/lib/libvirt/images/base/win11-base.comp.qcow2 && \
# sudo mv /var/lib/libvirt/images/base/win11-base.comp.qcow2 /var/lib/libvirt/images/base/win11-base.qcow2

# Lock it read-only (HOST Machine)
# sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/base/win11-base.qcow2
# sudo chmod 0444 /var/lib/libvirt/images/base/win11-base.qcow2
# (Optional, extra hardening; root needed to toggle later)
# sudo chattr +i /var/lib/libvirt/images/base/win11-base.qcow2

# NOTES:
# 1. Never boot a VM from the base after you lock it. Always create per‑VM children (backing files) for day‑to‑day use.
# 2. Keep the VirtIO ISO mounted during install so you can load storage + network drivers and install the QEMU Guest Agent.
# 3. If --os-variant isn’t recognized on your distro, query available IDs: osinfo-query os | grep -i windows.
