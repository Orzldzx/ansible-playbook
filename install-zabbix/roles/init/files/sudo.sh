#!/bin/bash

sed -i 's/^Defaults    requiretty/# Defaults    requiretty/' /etc/sudoers

if [[ $(grep -c 'visiblepw' /etc/sudoers) == 0 ]]; then
    sed -i "/$line/a\Defaults   visiblepw" /etc/sudoers
elif [[ $(grep -c 'visiblepw' /etc/sudoers) == 1 ]]; then
    var=$(grep -n 'visiblepw' /etc/sudoers)
    line=${var#*:}
    sed -i "s/$line/# $line/" /etc/sudoers
    sed -i "/$line/a\Defaults   visiblepw" /etc/sudoers
else
    exit 0
fi


cat >> /etc/sudoers << EOF


## Zabbix
Cmnd_Alias ZABBIX = /monitor/service/server-run, /monitor/service/sql-run, /monitor/system/io-all, /monitor/database/mysql/mysql_discovery.py

zabbix ALL = (root) NOPASSWD: ZABBIX
EOF
