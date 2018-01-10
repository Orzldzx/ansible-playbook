#!/bin/bash

if [[ $(swapon -s| wc -l) == 0 ]]; then
    cd /opt/
    dd if=/dev/zero of=swap1.file bs=1M count=4096
    mkswap swap1.file
    chmod 0600 swap1.file
    swapon swap1.file
    echo '/opt/swap1.file    swap    swap    defaults    0 0' >> /etc/fstab
fi
