#!/bin/bash

virt-install --osinfo almalinux9 --name al9-master-node --vcpus 2 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0 --location "/data1/libvirt/d1disks/AlmaLinux-9.3-x86_64-dvd.iso" --initrd-inject "/data1/kickstart/al9-master-node.cfg" --extra-args="inst.ks=file:/al9-master-node.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole --wait 0

virt-clone --replace --original al9-master-node --name kc2n1 --file /data1/libvirt/d1disks/kc2n1.qcow2
