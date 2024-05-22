# Kubernetes kubeadm cluster

One control three worker kubernetes cluster setup with kubeadm.

* Host hypervisor Fedora 39 using libvirt
* Nodes run Almalinux 9

## External config

Nodes are installed with kickstart files.

* virt-install with kickstart injection
* dhcp with automatic hostname dns registration
