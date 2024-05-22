# kc1 node ansible

## Test Playbooks

```bash
ansible-playbook -l kc2cluster -u localsysadmin -k -b -K ping.yaml
ansible-playbook -l kc2cluster -b ping_autouser.yaml

# First line of json callback is like "host => {" and not valid json.
ANSIBLE_CALLBACK_WHITELIST=json ANSIBLE_STDOUT_CALLBACK=json ansible -m gather_facts -u localsysadmin -k -b -K kc2n1 | sed "1s/.*/{/" | jq . | tee kc2n1_facts.json
```

## Support Playbooks

```bash
ansible-playbook -l kc2cluster -e sshfs_host=foxfire -b mount_kubeshare.yaml
ansible -m command -a "umount /home/localsysadmin/kubeshare" -b -K kc2cluster
```

## Install Playbooks

```bash
# Install first control node
ansible-playbook -l kc2control kcsetup_inet.yaml
ansible-playbook -l kc2control kcreset_inet.yaml
```

```bash
ansible-playbook -l kc2n1 kcsetup_inet.yaml
ansible-playbook -l kc2n1 kcreset_inet.yaml

ansible-playbook -l kc2worker kc_copy_kubeconfig.yaml
ansible -m command -a "sha1sum /root/.kube/config" -b -K kc2nodes

ansible-playbook -l kc2n2 kcsetup_inet.yaml
ansible-playbook -l kc2n2 kcreset_inet.yaml
ansible-playbook -l kc2n2 kc_add_worker_inet.yaml
```
