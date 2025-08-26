Build disposable Windows VMs for your home lab

Tired of building Windows VMs from scratch?
This project provides a repeatable pipeline for creating sysprepped base images and child VMs on a Linux host (Ubuntu + KVM). Ideal for testing Active Directory, SCCM/MECM, Group Policies, registry edits, print servers, and file shares in a safe, disposable lab environment.

⚡ Quick Start
# 1. Install host prerequisites (Ubuntu 24.04.1 / GNU/Linux)
sudo apt update && sudo apt install -y qemu-kvm libvirt-daemon-system virt-manager

# 2. Add your user to required groups
sudo usermod -aG kvm,libvirt $USER
newgrp libvirt

# 3. Download Windows + VirtIO ISOs
bash ./Get-Win_ISO.sh (uncomment respective ISO URL's before running)

# 4. Build a Windows 11 base image
bash ./qemu-kvm_win_11_base.sh

# 5. Build a disposable child VM from the base
bash ./c_win11_client.sh

👉 You now have a clean Windows 11 VM running on KVM, ready to break, test, and reset as often as you want.

###############################################################################

⚙️ Build Runbooks

Windows 11 Base
Script: qemu-kvm_win_11_base.sh
Ensure host prerequisites are installed; add user to libvirt + kvm groups.
Download Windows 11 ISO + VirtIO ISO (Get-Win_ISO.sh).

Run:
bash ./qemu-kvm_win_11_base.sh
During Windows setup, load VirtIO storage + network drivers from the VirtIO ISO.
Install guest tools, apply updates.
Run sysprep:
Sysprep.exe /generalize /oobe /shutdown /mode:vm

Windows Server Base
Script: qemu-kvm_win_srv_base.sh
Steps mirror Windows 11, with server-specific VirtIO paths.
Ensure host prerequisites are installed; user in libvirt + kvm.
Download Windows Server ISO + VirtIO ISO (Get-Win_ISO.sh).

Run:
bash ./qemu-kvm_win_srv_base.sh
Load VirtIO drivers.
Install guest tools.
Run sysprep + shutdown.

Child VMs
Scripts:
Windows 11 Client → c_win11_client.sh
Windows Server → c_win_server.sh
These scripts clone from the locked base image to rapidly spin up new lab VMs.

🪟 Windows Setup Details
Windows 11 Setup (Inside VM-Windows11)
When disks aren’t visible, click Load driver → browse the VirtIO ISO drive.
Load Stor driver from:
vioscsi\w11\amd64 (recommended)
or viostor\w11\amd64 if using virtio-blk.
Proceed with install.
After first login, from the VirtIO ISO run:
virtio-win-guest-tools.exe
(installs NetKVM, Balloon, QEMU Guest Agent, etc.)
Apply minimal baseline tweaks/updates you want baked into the gold image.
Generalize base (admin PowerShell):
C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /mode:vm

Post Windows 11 Setup (Host Machine)
(Optional) compact/compress:
sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/base/win11-base.qcow2 \
 /var/lib/libvirt/images/base/win11-base.comp2.qcow2 && \
sudo mv /var/lib/libvirt/images/base/win11-base.comp2.qcow2 /var/lib/libvirt/images/base/win11-base.qcow2

Lock it read-only:
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/base/win11-base.qcow2
sudo chmod 0444 /var/lib/libvirt/images/base/win11-base.qcow2
sudo chattr +i /var/lib/libvirt/images/base/win11-base.qcow2   # optional hardening

Windows Server Setup (Inside VM-WindowsServer)
Load driver from VirtIO ISO:
vioscsi\2k22\amd64 (for 2022)
or 2k19/2k25 to match your version.
Finish install, log in, run virtio-win-guest-tools.exe.
Apply minimal base tweaks/updates for gold image.
Generalize base (admin PowerShell):
C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown /mode:vm

Post Windows Server Setup (Host Machine)
(Optional) compact/compress:
sudo qemu-img convert -O qcow2 -c /var/lib/libvirt/images/base/win11-base.qcow2 \
 /var/lib/libvirt/images/base/win11-base.comp.qcow2 && \
sudo mv /var/lib/libvirt/images/base/win11-base.comp.qcow2 /var/lib/libvirt/images/base/win11-base.qcow2

Lock it read-only: 
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/base/win11-base.qcow2
sudo chmod 0444 /var/lib/libvirt/images/base/win11-base.qcow2
sudo chattr +i /var/lib/libvirt/images/base/win11-base.qcow2   # optional hardening


NOTES:
Never boot directly from the base after locking it. Always use children.
Keep VirtIO ISO mounted during setup for storage + network drivers.
If --os-variant isn’t recognized, query available IDs:
osinfo-query os | grep -i windows

📌 Notes
Base images are sysprepped and locked read-only to ensure clean children.
Built for Linux host environments today; Windows host support in progress.
Ideal for home labs, testing, and continuous learning.

🚀 Roadmap
Windows host environment support.
Automated post-install configuration (updates, GPO templates, AD roles).
CI/CD integration for automated lab refresh.
