#!/bin/bash

if pgrep -x "libvirtd" > /dev/null; then
    systemctl stop libvirtd.service
    echo "libvirtd.service stopped..."
else 
    systemctl start libvirtd.service
    echo "libvirtd.service running..."
fi

if sudo virsh list --state-running | grep -q "ubuntu"; then
    sudo virsh destroy ubuntu
    echo "virsh ubuntu destroyed..."
else
    sudo virsh net-start default
    sudo virsh start ubuntu
    echo "virsh ubuntu running..."
fi

if pgrep -x "virt-manager" > /dev/null; then
    pkill -x "virt-manager"
    echo "virt-manager killed..."
else
    sudo virt-manager \
        --connect qemu:///system \
        --show-domain-console ubuntu
    echo "virt-manager started..."
fi