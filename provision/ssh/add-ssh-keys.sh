#!/bin/bash

ssh-keyscan -v kc1n1 kc1n2 kc1n3 kc1n4 >> ~/.ssh/known_hosts

ssh-copy-id kc1n1
ssh-copy-id kc1n2
ssh-copy-id kc1n3
ssh-copy-id kc1n4
