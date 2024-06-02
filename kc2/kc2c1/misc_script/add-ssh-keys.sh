#!/bin/bash

ssh-keyscan -v \
kc2n1 kc2n2 kc2n3 kc2n4 kc2sup \
>> ~/.ssh/known_hosts

ssh-copy-id kc2n1
ssh-copy-id kc2n2
ssh-copy-id kc2n3
ssh-copy-id kc2n4
ssh-copy-id kc2sup

