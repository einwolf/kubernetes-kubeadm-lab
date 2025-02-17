#!/bin/bash

export VIRSH_DEFAULT_CONNECT_URI=qemu:///system

virsh reboot kc1n1
virsh reboot kc1n2
virsh reboot kc1n3
virsh reboot kc1n4
