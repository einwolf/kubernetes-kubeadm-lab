# Cilium CNI

Cilium 0.16 and up use helm to install.
Even ciliumcli install uses helm internally.

```bash
# --plain-http
# --insecure-skip-tls-verify
# --repo
# --destination dirpath
# --debug

# cilium cli
https://github.com/cilium/cilium-cli/releases/download/v0.16.16/cilium-linux-amd64.tar.gz
# tar has only cilium program inside
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v0.16.16/cilium-linux-amd64.tar.gz{,.sha256sum}
sudo tar -xzvf cilium-linux-amd64.tar.gz -C /usr/local/bin
# Don't know how to redirect it yet
cilium install --version 1.16.1

# helm only
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.16.1 --namespace kube-system

helm pull cilium/cilium --version 1.16.1

```
