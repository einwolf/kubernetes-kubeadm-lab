# kc2-multi1 node ansible

multi1 installs from internet.

```bash
# community.libvirt.libvirt inventory
ansible-inventory -i libvirt-inventory.yaml --list
```

## Test Playbooks

```bash
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -l kc1cluster -u localsysadmin -k -b -K ping.yaml
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -l kc1nodes -b ping_autouser.yaml

# json callback is in ansible-collection-ansible-posix.noarch
# First line of json callback is like "host => {" and not valid json.
ANSIBLE_CALLBACK_WHITELIST=json ANSIBLE_STDOUT_CALLBACK=json ansible -m gather_facts -u localsysadmin -k -b -K kc1n1 | sed "1s/.*/{/" | jq . | tee kc1n1_facts.json
```

## Support Playbooks

```bash
ansible -m command -a "dnf install -y python3-jmespath" -b -k -K kc1cluster
ansible -m reboot -b -k -K kc1nodes
```

```bash
ansible-playbook -l kc1cluster -e sshfs_host=foxfire -b mount_kubeshare.yaml
ansible -m command -a "umount /home/localsysadmin/kubeshare" -b -k -K kc1cluster
```

## Install Playbooks

```bash
# Install first control node
ansible-playbook -l kc1n1 kcsetup_inet.yaml

# Distribute admin kubeconfig
ansible-playbook -l kc1worker -e copy_from_hostname=kc1n1 kc_copy_kubeconfig.yaml
ansible-playbook -l kc1worker,kc1support -e copy_from_hostname=kc1n1 kc_copy_kubeconfig.yaml
ansible -m command -a "sha256sum /root/.kube/config" -b -K kc1nodes

# Install worker
ansible-playbook -l kc1n2 -e kc_control_name=kc1n1 kc_add_worker_inet.yaml
ansible-playbook -l kc1worker -e kc_control_name=kc1n1 kc_add_worker_inet.yaml

# Destroy cluster
# Remove worker nodes then control nodes
ansible-playbook -l kc1control -e kc_control_name=kc1n1 kcreset_inet.yaml
ansible-playbook -l kc1worker -e kc_control_name=kc1n1 kcreset_inet.yaml

ansible -m command -a "kubeadm reset --force" -b -K kc1worker
```

```bash
# k8s facts test
ansible-playbook -v -l kc1control -e kc_control_name=kc1n1 kc_facts.yaml

# Set control node to run any container
ansible-playbook -v -l kc1control kc_node_untaint_cp.yaml
kubectl taint node kc1n1 node-role.kubernetes.io/control-plane-

# Kill pods at cri-o level
ansible-playbook -v -l kc1control crio_kill_pods.yaml
```

```bash
# Install kubernetes features (run against one control node)
ansible-playbook -l kc1n1 kc_install_metrics_inet.yaml

ansible-playbook -l kc1n1 kc_install_dashboard_inet.yaml
```

## Problems

```bash
# Can't handle creating more than one control node at once
ansible-playbook -l kc1control kcsetup_inet.yaml
```
