# Windows-Lab-Tools
Build Disposable VM's for your home labs.

Build the Base versions first.....
Download Windows ISO's and Virtoio-win.iso (guest tools)
# Architecture: Ubuntu 24.04.1, GNU/LINUX KVM
- **Base image pipeline** → sysprepped `qcow2` under an images directory.
- **Child VMs** → `qcow2` with `-b base.qcow2` backing; explicit `-F qcow2`.
- **VirtIO** drivers and QEMU guest tools installed in base image.
- **Sysprep** on base; lock read-only post-build.

# Build Windows 11 Base – Runbook (see "qemu-kvm_win_11_base.sh")
1) Ensure host prereqs installed; user in `libvirt` and `kvm` groups.
2) Download Windows and VirtIO ISOs (see Get-Win_ISO.sh).
3) Run: `bash ./qemu-kvm_win_11_base.sh`.
4) In Windows setup: load VirtIO storage/network drivers from the VirtIO ISO.
5) Install guest tools, Windows updates as needed.
6) Sysprep: `Sysprep.exe /generalize /oobe /shutdown /mode:vm`.

# Build Windows Server Base – Runbook (see "qemu-kvm_win_srv_base.sh")
Steps mirror Windows 11 with server-specific VirtIO drivers path.
1) Ensure host prereqs installed; user in `libvirt` and `kvm` groups.
2) Download Server and VirtIO ISOs (see see "Get-Win_ISO.sh").
3) Run: `bash ./qemu-kvm_win_srv_base.sh`.
4) Load VirtIO storage/network drivers from the VirtIO ISO.
5) Install guest tools.
6) Sysprep and shut down.

# Build Child VM's – Runbook (see "c_win11_client.sh" "c_win_server.sh")
Windows 11 Client VM:  c_win11_client.sh \
   Windows Server VM:  c_win_server.sh
