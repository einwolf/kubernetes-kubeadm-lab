#!/bin/bash

rsync -rvtp --delete ~/github-einwolf/kubernetes-kubeadm-lab/kc1 kc1n1:/root/kc1
rsync -rvtp --delete ~/github-einwolf/kubernetes-kubeadm-lab/kc1 kc1n2:/root/kc1
rsync -rvtp --delete ~/github-einwolf/kubernetes-kubeadm-lab/kc1 kc1n3:/root/kc1
rsync -rvtp --delete ~/github-einwolf/kubernetes-kubeadm-lab/kc1 kc1n4:/root/kc1
