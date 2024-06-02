# kc2c1 node ansible

kc2c1 installs from internet.

## Test Playbooks

```bash
ansible-playbook -l kc2cluster -u localsysadmin -k -b -K ping.yaml
ansible-playbook -l kc2cluster -b ping_autouser.yaml

# json callback is in ansible-collection-ansible-posix.noarch
# First line of json callback is like "host => {" and not valid json.
ANSIBLE_CALLBACK_WHITELIST=json ANSIBLE_STDOUT_CALLBACK=json ansible -m gather_facts -u localsysadmin -k -b -K kc2n1 | sed "1s/.*/{/" | jq . | tee kc2n1_facts.json
```

## Support Playbooks

```bash
ansible -m command -a "dnf install -y python3-jmespath" -k -b -K kc2cluster
```

```bash
ansible-playbook -l kc2cluster -e sshfs_host=foxfire -b mount_kubeshare.yaml
ansible -m command -a "umount /home/localsysadmin/kubeshare" -k -b -K kc2cluster
```

## Install Playbooks

```bash
# Install first control node
ansible-playbook -l kc2n1 kcsetup_inet.yaml

# Destroy cluster
# Remove worker nodes then control nodes
ansible-playbook -l kc2control -e kc_control_name=kc2n1 kcreset_inet.yaml
ansible-playbook -l kc2worker -e kc_control_name=kc2n1 kcreset_inet.yaml

# Distribute admin kubeconfig
ansible-playbook -l kc2worker -e copy_from_hostname=kc2n1 kc_copy_kubeconfig.yaml
ansible-playbook -l kc2worker,kc2support -e copy_from_hostname=kc2n1 kc_copy_kubeconfig.yaml
ansible -m command -a "sha256sum /root/.kube/config" -b -K kc2nodes

# Install worker
ansible-playbook -l kc2n2 -e kc_control_name=kc1n1 kc_add_worker_inet.yaml
ansible-playbook -l kc2worker -e kc_control_name=kc1n1 kc_add_worker_inet.yaml
```

```bash
# k8s facts test
ansible-playbook -v -l kc2control -e @kc2_vars.yaml kc_facts.yaml


# Set control node to run any container
ansible-playbook -v -l kc2control kc_node_untaint_cp.yaml
kubectl taint node kc2n1 node-role.kubernetes.io/control-plane-
```

```bash
# Install kubernetes features (run against one control node)
ansible-playbook -l kc2n1 kc_install_metrics_inet.yaml

ansible-playbook -l kc2n1 kc_install_dashboard_inet.yaml
```

## Problems

```bash
# Can't handle creating more than one control node at once
ansible-playbook -l kc2control kcsetup_inet.yaml
```
