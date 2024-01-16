# libvirt configuration

## Storage

```bash
pool-define-as --type dir --name d1disks --target /data1/libvirt/d1disks
```

## Network

```bash
# Add NetworkManager bridge for libvirt
nmcli con add ifname br0 type bridge con-name bridge0
nmcli con add type bridge-slave ifname enp3s0 master bridge0
nmcli con modify bridge0 bridge.stp no
nmcli con up bridge0
nmcli con show bridge0
```

```bash
# Add libvirt bridged network
# virsh doesn't have a lot of non-xml commands
virsh net-define br0.xml
virsh net-start br0
virsh net-autostart br0
virsh net-list --all
```

```xml
<!-- br0.xml -->
<network>
  <name>br0</name>
  <forward mode="bridge"/>
  <bridge name="br0" />
</network>
```

## Virtual Machines

```bash
# Delete existing
virsh destroy kubehard1-c1
virsh undefine --remove-all-storage kubehard1-c1
```

```bash
# pxe
# almalinux9 rhel9.4 rhel9-unknown
virt-install --osinfo almalinux9 --name kubehard1-c1 --vcpus 4 --memory 8192 --disk pool=d1disks,size=100 --network=bridge:br0 --pxe
```

```bash
# Set mac address
--network=bridge:br0,mac=12:34:12:34:12:34
```

## Kubehard Cluster 1

```bash
virsh destroy kubehard1-c1
virsh undefine --remove-all-storage kubehard1-c1
```

```bash
# kickstart
virt-install --osinfo almalinux9 --name kh1n1 --vcpus 4 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0 --location "/data1/libvirt/d1disks/AlmaLinux-9.3-x86_64-dvd.iso" --initrd-inject "/data1/kickstart/kh1n1.cfg" --extra-args="inst.ks=file:/kh1n1.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole --wait 0
```
