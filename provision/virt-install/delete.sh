#!/bin/bash

virsh destroy kc1n1
virsh undefine --remove-all-storage kc1n1

virsh destroy kc1n2
virsh undefine --remove-all-storage kc1n2

virsh destroy kc1n3
virsh undefine --remove-all-storage kc1n3

virsh destroy kc1n4
virsh undefine --remove-all-storage kc1n4
