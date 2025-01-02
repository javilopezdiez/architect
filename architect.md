
<!-- 
# TOIN
# TODO 
-->

##### Architect Install ####
# IMAGE DOWNLOAD
```bash
wget https://es.mirrors.cicku.me/archlinux/iso/2024.12.01/archlinux-2024.12.01-x86_64.iso --show-progress
```

# VM
```bash
    # VM manager + QEMU
        yay -S virt-manager qemu
        sudo systemctl status libvirtd.service
        sudo systemctl start libvirtd.service
    # Startig by default VM interaction form terminal
        # sudo virsh net-start default
        # sudo virsh net-autostart default
    # Listing
        sudo virsh net-list --all
    # add user so that we don't get prompt for pass
        # sudo usermod -aG libvirt $USER && \
        # sudo usermod -aG libvirt-qemu $USER && \
        # sudo usermod -aG kvm $USER && \
        # sudo usermod -aG input $USER && \
        # sudo usermod -aG disk $USER
```

# INSTALLATION
```bash
curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect.sh && sudo bash architect.sh > architect.log
```


