#!/bin/bash

export LIBVIRT_DEFAULT_URI=qemu:///system

virt-install --osinfo almalinux9 --name kc1n1 --vcpus 4 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0,mac=52:54:00:7c:53:e8 --location "/data1/libvirt/d1isos/AlmaLinux-9.5-x86_64-dvd.iso" --initrd-inject "/data1/kickstarts/kc1n1-ks.cfg" --extra-args="inst.ks=file:/kc1n1-ks.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole

virt-install --osinfo almalinux9 --name kc1n2 --vcpus 4 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0,mac=52:54:00:02:5c:df --location "/data1/libvirt/d1isos/AlmaLinux-9.5-x86_64-dvd.iso" --initrd-inject "/data1/kickstarts/kc1n2-ks.cfg" --extra-args="inst.ks=file:/kc1n2-ks.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole

virt-install --osinfo almalinux9 --name kc1n3 --vcpus 4 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0,mac=52:54:00:6d:2d:7e --location "/data1/libvirt/d1isos/AlmaLinux-9.5-x86_64-dvd.iso" --initrd-inject "/data1/kickstarts/kc1n3-ks.cfg" --extra-args="inst.ks=file:/kc1n3-ks.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole

virt-install --osinfo almalinux9 --name kc1n4 --vcpus 4 --memory 8192 --disk pool=d1disks,size=200 --network=bridge:br0,mac=52:54:00:0b:9b:ba --location "/data1/libvirt/d1isos/AlmaLinux-9.5-x86_64-dvd.iso" --initrd-inject "/data1/kickstarts/kc1n4-ks.cfg" --extra-args="inst.ks=file:/kc1n4-ks.cfg console=tty0 console=ttyS0,115200n8" --noautoconsole
