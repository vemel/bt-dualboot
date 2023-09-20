#!/usr/bin/env bash

set -euo pipefail

mkdir -p tmp
sudo rm -rf ./tmp/bluetooth || true
sudo cp -r /var/lib/bluetooth ./tmp/bluetooth
sudo chmod -R a+rwx ./tmp/bluetooth

WIN_MNT=`findmnt --json | jq -r '.filesystems[].children[] | select(.fstype | contains("ntfs")) | .target'`
if [ "$WIN_MNT" == "null" ]; then
    echo "Windows partition not found"
    echo "Mount it in Files and try again"
    exit 1
fi
echo "Windows mounted to" $WIN_MNT

poetry run bt-dualboot -l --bluetooth-path ./tmp/bluetooth --win "$WIN_MNT"

# poetry run bt-dualboot --sync-all --win "$WIN_MNT" --bluetooth-path ./tmp/bluetooth -b /tmp/backup
