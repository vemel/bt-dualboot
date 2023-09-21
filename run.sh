#!/usr/bin/env bash

set -euo pipefail

SYS_BLUETOOTH_PATH="/var/lib/bluetooth"
TEMP_BLUETOOTH_PATH="./tmp/bluetooth"
BACKUP_PATH="./tmp/backup"
WIN_MNT=""

has_param() {
    local term="$1"
    shift
    for arg; do
        if [[ $arg == "$term" ]]; then
            return 0
        fi
    done
    return 1
}

copy_bluetooth_dir() {
    sudo rm -rf $TEMP_BLUETOOTH_PATH || true
    mkdir -p $(dirname "$TEMP_BLUETOOTH_PATH")
    sudo cp -r $SYS_BLUETOOTH_PATH $TEMP_BLUETOOTH_PATH
    sudo chmod -R a+rwx $TEMP_BLUETOOTH_PATH
}

find_win_mnt() {
    WIN_MNT=`findmnt --json | jq -r '.filesystems[].children[] | select(.fstype | contains("ntfs")) | .target'`
    echo $WIN_MNT
    if [ "$WIN_MNT" == "" ]; then
        echo "Windows ntfs partition not mounted"
        echo "Mount it in Files and try again"
        exit 1
    fi
    echo "Windows mounted to" $WIN_MNT
}

list_devices() {
    poetry run bt-dualboot -l --bluetooth-path $TEMP_BLUETOOTH_PATH --win "$WIN_MNT"
}

sync_all() {
    echo "Syncing..."
    poetry run bt-dualboot --sync-all --win "$WIN_MNT" --bluetooth-path $TEMP_BLUETOOTH_PATH -b $BACKUP_PATH
}

copy_bluetooth_dir
find_win_mnt
list_devices

if has_param '--sync' "$@"; then
    sync_all
fi
