# Kubernetes kubeadm cluster

One control three worker kubernetes cluster setup with kubeadm.

* Host hypervisor Fedora 39 using libvirt
* Nodes run Almalinux 9.3

## External config

Nodes are installed with kickstart files.

* virt-install with kickstart injection
* dhcp with automatic hostname dns registration

## kc1

Manually installed kubernetes v1.28 with notes.

## kc2

Ansible installed from internet

* kc2c1 - calico
