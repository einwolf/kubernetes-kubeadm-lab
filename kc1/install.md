# kubeadm setup

## Ports

<https://docs.tigera.io/calico/latest/getting-started/kubernetes/requirements>

| port | proto |
| --- | --- |
| 179  | tcp bgp |
| 4789 | udp vxlan |

## ubi9

```bash
kubectl run -it ubi9 --image registry.access.redhat.com/ubi9 -- /bin/bash
kubectl run ubi9 --image registry.access.redhat.com/ubi9
```

## System setup

```bash
cp -vf files/dotbashrc /root/.bashrc
# cp -vf files/etc/resolv.conf-dnsmasq /etc/resolv.conf
cp -vf files/etc/sysctl.d/90-kubernetes.conf /etc/sysctl.d/
cp -vf files/etc/modules-load.d/kubernetes.conf /etc/modules-load.d/

# Disable FIPS Active directory requiring RC4
update-crypto-policies --set FIPS:AD-SUPPORT

# Disable FIPS TLS 1.2 requiring extended master secret
update-crypto-policies --set FIPS:NO-ENFORCE-EMS
```

```bash
# Unknown problems
/etc/resolv.conf is not created by NetworkManager when selinux enforcing is on.
```

Not sure what creates resolv.conf.

* NetworkManager - no?
* systemd-resolved?

## kubeadm init

```bash
# Copy install repo files
cp -vf files/etc/yum.repos.d/*.repo /etc/yum.repos.d/

# Remove swap
swapoff -a
# Edit fstab to remove swap

# Make sure sysctl.conf and modules-load.conf are set
# Check for resolv.conf

# Install cri-o
# kubeadm recognizes docker engine (moby?), containerd, cri-o.
# Not runc or crun (are OCI runtimes not CRI runtimes)
dnf install -y cri-o cri-tools
# cp -vf files/etc/sysconfig/crio /etc/sysconfig/crio # proxy
systemctl enable --now crio

# cri-o v1.24.6 doesn't understand keyPaths list in /etc/containers/policy.json.
# Edit it to have keyPath with one key.

# cri-o v1.28.2 is ok with keyPaths.

# Download test
crictl pull quay.io/podman/hello
crictl images
# Hard to run from crictl
podman run quay.io/podman/hello:latest

# Install kubernetes
# This repo has a newer cri-tools
# The repo has an exclude=kubectl kubeadm kubelet cri-tools kubernetes-cni to keep it from updating major versions.
dnf install -y --disableexcludes=kubernetes kubectl kubeadm kubelet
crictl completion bash > /etc/bash_completion.d/crictl
kubeadm completion bash > /etc/bash_completion.d/kubeadm
kubectl completion bash > /etc/bash_completion.d/kubectl
chmod -v 0664 /etc/bash_completion.d/{crictl,kubeadm,kubectl}

systemctl enable kubelet
#sysctl --system
#modprobe br_netfilter

# Test removing the cri-o cni
mkdir -v /etc/cni/net.d/off
mv -v /etc/cni/net.d/100-crio-bridge.conflist /etc/cni/net.d/200-loopback.conflist /etc/cni/net.d/off

# First control node
kubeadm init --config kubeadm-config.yaml

# Worker node
# join command from kubeadm init
kubeadm token create --print-join-command
```

```bash
# Check kubeadmin authentication
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes

# Remove control-plane role
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## kubeadm reset

```bash
kubeadm reset

# Don't delete the cri-o files
rm -rfv /etc/cni/net.d/*calico*
```

## Calico tigera operator
```bash
# Calico using operator

# Keep network manager from managing calico interfaces
cp -vp files/etc/NetworkManager/conf/calico.conf /etc/NetworkManager/conf/calico.conf
chmod -v 0664 /etc/NetworkManager/conf/calico.conf

# operator
#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
#kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

kubectl create -f tigera-operator.yaml
kubectl create -f calico-custom-resources.yaml

curl -L https://github.com/projectcalico/calico/releases/download/v3.27.2/calicoctl-linux-amd64 -o calicoctl-v3.27.2
# Some pods never init. Internet access/download problem?
```

## Calico manifests

```bash
# Calico using manifests

# Keep network manager from managing calico interfaces
cp -vp files/etc/NetworkManager/conf.d/calico.conf /etc/NetworkManager/conf.d/calico.conf
chmod -v 0664 /etc/NetworkManager/conf.d/calico.conf

# manifests
curl -L https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml -o calico-v3.27.2.yaml
curl -L https://github.com/projectcalico/calico/releases/download/v3.27.2/calicoctl-linux-amd64 -o calicoctl-v3.27.2
# Set CALICO_IPV4POOL_CIDR

# Deploys into kube-system
kubectl apply -f cni/calico/calico-v3.27.2.yaml

# Remove calico
kubectl delete -f cni/calico/calico-v3.27.2.yaml
# /etc/NetworkManager/conf/calico.conf is ok to leave when reinstalling
rm -vf /etc/NetworkManager/conf/calico.conf
rm -rfv /etc/cni/net.d/{10-calico.conflist,calico-kubeconfig}
# Note /etc/cni/100-crio-bridge.conflist /etc/cni/200-loopback.conflist come from cri-o.
# Removing them messes up the cri-o bridge for pod networking.

```

## Troubleshooting calico

Some of the containers are not starting with AccessDenied errors. Deleting them causes them to start ok.

```bash
# Examples
calico-kube-controllers

kubectl delete pods --all --all-namespaces
```

## Cilium CNI

```bash
# Cilium
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v0.15.20/cilium-linux-amd64.tar.gz

mv cilium ~/.local/bin
cilium install --version 1.14.5
```
