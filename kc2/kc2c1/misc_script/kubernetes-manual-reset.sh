#!/bin/bash

# Any pods created need to be deleted also
systemctl stop kubelet

# kubernetes
rm -rfv /etc/kubernetes/*.conf
rm -rfv /etc/kubernetes/manifests/*.yaml
rm -rfv /etc/kubernetes/pki/*.{key,crt}
rm -rfv /var/lib/kubelet/*

# Listed in kubeadm rest
rm -rfv /etc/kubernetes/admin.conf /etc/kubernetes/super-admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf

# etcd
rm -rfv /var/lib/etcd/*

# calico cni
# calico also replaces files in /opt/cni/bin
rm -rfv /var/lib/cni/networks/*
rm -rfv /var/lib/cni/results/*

# iptables
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
#ipvsadm -C # Not installed
