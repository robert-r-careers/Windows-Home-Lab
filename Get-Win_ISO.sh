#!/bin/bash
##########################################################################################
# Download ISO's:                                                                        #
#  Windows ISO: https://www.microsoft.com/en-us/evalcenter                               #
#  Windows Virtio: https://fedorapeople.org/groups/virt/virtio-win                       #
##########################################################################################

# Download directory

DEST_DIR="$(whoami)/Downloads/ISOs"
mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit

# ISO Links (uncomment to Download ISO)
urls=(
  "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso" # Virtio-Win ISO
 # "https://go.microsoft.com/fwlink/?linkid=2293312&clcid=0x409&culture=en-us&country=us"  # Windows Server 2025
  "https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US" # Windows Server 2022
 # "https://go.microsoft.com/fwlink/p/?LinkID=2195167&clcid=0x409&culture=en-us&country=US" # Windows Server 2019
  "https://go.microsoft.com/fwlink/?linkid=2289031&clcid=0x409&culture=en-us&country=us"  # Windows 11 Enterprise
 # "https://go.microsoft.com/fwlink/?linkid=2289029&clcid=0x409&culture=en-us&country=us"  # Windows 11 Enterprise LTSC
)

# Download each ISO
for url in "${urls[@]}"; do
  aria2c -x 16 -s 16 -c \
    --max-connection-per-server=16 \
    --min-split-size=1M \
    --auto-file-renaming=false \
    --remote-time=true \
    --check-certificate=true \
    --content-disposition=true \
    "$url"
done

echo "Downloads saved to: $DEST_DIR"

