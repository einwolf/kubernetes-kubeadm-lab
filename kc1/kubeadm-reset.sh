#!/bin/bash

kubeadm reset
rm -rfv /etc/cni/net.d/*
systemctl stop kubelet
systemctl restart crio

# /etc/kubernetes is empty
# /var/lib/kubelet is empty
# /var/lib/etcd is empty
