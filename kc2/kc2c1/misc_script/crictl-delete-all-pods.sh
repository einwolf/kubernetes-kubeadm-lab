#!/bin/bash

PODS=$(crictl pods | cut -d " " -f 1 | tail -n +2)

for POD in $PODS
do
    echo crictl stopp $POD
    crictl stopp $POD

    echo crictl rmp $POD
    crictl rmp $POD
done
