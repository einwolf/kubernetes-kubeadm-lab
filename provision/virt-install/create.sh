#!/bin/bash

virt-install --osinfo almalinux9 --name kc1n1 --vcpus 2 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0 --location "/data1/libvirt/d1disks/AlmaLinux-9.3-x86_64-dvd.iso" --initrd-inject "/data1/kickstart/kc1n1.cfg" --extra-args="inst.ks=file:/kc1n1.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole --wait 0

virt-install --osinfo almalinux9 --name kc1n2 --vcpus 2 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0 --location "/data1/libvirt/d1disks/AlmaLinux-9.3-x86_64-dvd.iso" --initrd-inject "/data1/kickstart/kc1n2.cfg" --extra-args="inst.ks=file:/kc1n2.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole --wait 0

virt-install --osinfo almalinux9 --name kc1n3 --vcpus 2 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0 --location "/data1/libvirt/d1disks/AlmaLinux-9.3-x86_64-dvd.iso" --initrd-inject "/data1/kickstart/kc1n3.cfg" --extra-args="inst.ks=file:/kc1n3.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole --wait 0

virt-install --osinfo almalinux9 --name kc1n4 --vcpus 2 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0 --location "/data1/libvirt/d1disks/AlmaLinux-9.3-x86_64-dvd.iso" --initrd-inject "/data1/kickstart/kc1n4.cfg" --extra-args="inst.ks=file:/kc1n4.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole --wait 0
