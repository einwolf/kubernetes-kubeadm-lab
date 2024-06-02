# Misc

## Linux Namespaces

```bash
lsns -t network
ip netns list
ip netns identify <pid>
```

## Access kubernetes url using curl

<https://stackoverflow/questions/69412035/use-the-kubernetes-rest-api-without-kubectl>

Can put in -k to skip --cacert.

```bash
# kubeproxy authenticates as $KUBECONFIG
kubectl proxy --port=8080
curl http://localhost:8080/api/
curl http://localhost:8080/apis/crd.projectcalico.org/v1/clusterinformations/default
```

```bash
# curl uses client certificates
curl -iv -L \
--cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
--key /etc/kubernetes/pki/apiserver-kubelet-client.key \
--cacert /etc/kubernetes/pki/apiserver.crt \
https://10.2.18.31:6443/api/

# or
http://localhost:8080/apis/crd.projectcalico.org/v1/clusterinformations/default
```

```bash
# curl uses calico certificates
curl -iv -L \
--cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
--key /etc/kubernetes/pki/apiserver-kubelet-client.key \
--cacert /etc/kubernetes/pki/apiserver.crt \
https://10.2.18.31:6443/api/

# or
http://localhost:8080/apis/crd.projectcalico.org/v1/clusterinformations/default
```

```bash
# Using kubeconfig to certificates
# ex: /etc/kubernetes/admin.conf
certificate-authority-data -> server.crt
client-certificate-data -> client.crt
client-key-data -> client.key

x | base64 -d > client.crt
openssl x509 -in client.crt -noout -text
curl -iv -L --cert cert.crt --key cert.key \
--cert client.crt --key client.key --cacert server.crt \
https://10.2.18.31:6443/api/v1/namespaces/default/pods
```

```bash
# Using token as in calico-kubeconfig
curl -iv -L --cacert /etc/kubernetes/pki/apiserver.crt \
-H "Authorization: Bearer <token here>" \
https://10.96.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default
```

```bash
kubectl --kubeconfig /etc/cni/net.d/calico-kubeconfig auth can-i get clusterinformations --all-namespaces
```

## podman and selinux volume mounts

```bash
#z is shared (any container can access)
#Z is private (last container launched can access)
podman run -v hostdir:contdir:ro,z -p hostport:contport hello

# z or Z switches the Selinux MCS category field (c). The type is still container_file_t.
# user role type sensitivity category
system_u:object_r:container_file_t:s0:c602
```

## Use etcdctl

Use etcdctl in the etcd container to query etcd.

The kubernetes system containers normally don't have utilities
but this container has /bin/sh. (ls doesn't work?)

```yaml
# The etc container is a static pod created from /etc/kubernetes/manifests/etcd.yaml
# The etcd container has these volume mounts.
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
```

```bash
kubectl exec -n kube-system -it etcd-kc1n1 -- /usr/local/bin/etcdctl

# In container
kubectl exec -n kube-system -it etcd-kc1n1 -- /usr/local/bin/etcdctl \
--endpoints 10.2.18.31:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
get /registry/ --prefix --keys-only

# Copied out etcdctl
/usr/local/bin/etcdctl \
--endpoints 10.2.18.31:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
get /registry/ --prefix --keys-only

```

## Set a default namespace on a config context

```bash
kubectl config set-context kube-system --namespace kube-system --cluster kubernetes --user kubernetes-admin
kubectl config use-context kube-system
```

## CNI network ip space

```bash
# cri-o only
# cni0 has 10.85.0.1/16 which is configured by 100-crio-bridge.conflist
# a ubi9 gets eth0@if9 with 10.85.0.4/16 connected to veth335e4257@if3

# Calico
# Calico creates tunl0 with ip 10.244.0.128/32.
# 10.244.0.0/24 is the Calico pod ip pool
# Needs to be part of cluster ip pool
# ->podSubnet: "10.244.0.0/24" in kubeadm config.yaml.
```

## calicoctl node checksystem

`calicoctl node checksystem` as of 3.27.0 is not updated for RHEL 9.
It appears to date from 3.10 and doesn't appear to be useful output.

<https://github.com/projectcalico/calico/issues/4288>

```bash
Checking kernel version...
		5.14.0-362.8.1.el9_3.x86_64					OK
Checking kernel modules...
		ipt_rpfilter        					OK
		xt_rpfilter         					OK
		xt_conntrack        					OK
		xt_set              					OK
WARNING: Unable to detect the xt_u32 module as Loaded/Builtin module or lsmod
		xt_u32              					FAIL
		ip_set              					OK
		ip6_tables          					OK
		xt_bpf              					OK
		ipt_REJECT          					OK
		nf_conntrack_netlink					OK
		xt_addrtype         					OK
		xt_mark             					OK
		xt_multiport        					OK
		ipt_ipvs            					OK
WARNING: Unable to detect the ipt_set module as Loaded/Builtin module or lsmod
		ipt_set             					FAIL
		ip_tables           					OK
		vfio-pci            					OK
WARNING: Unable to detect the xt_icmp module as Loaded/Builtin module or lsmod
		xt_icmp             					FAIL
WARNING: Unable to detect the xt_icmp6 module as Loaded/Builtin module or lsmod
		xt_icmp6            					FAIL
System doesn't meet one or more minimum systems requirements to run Calico
```

```bash
# ipt_set is in xt_set
[root@kc1n1 kc1n1]# modinfo xt_set -F alias
ip6t_SET
ipt_SET
ip6t_set
ipt_set
xt_SET

xt_u32    # removed in RHEL 9
xt_icmp
xt_icmp6
```

## Calico node host interface

Calico autodetects what interface to use on the host for its overlay network.
Auto is the first interfaces listed. Is it from `nmcli connection show` or `ip link show`?

<https://github.com/projectcalico/calico/issues/2561>

<https://docs.tigera.io/calico/latest/networking/ipam/ip-autodetection>

```bash
kubectl -n kube-system set env daemonset/calico-node IP=interface=ens192
```
