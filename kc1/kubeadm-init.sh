#!/bin/bash

kubeadm init --config kubeadm-config.yaml 2>&1 | tee kubeadm-init.txt
