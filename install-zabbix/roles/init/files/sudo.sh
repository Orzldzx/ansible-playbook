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
    # exit 0
    echo
fi

if [[ $(/bin/grep -ic 'zabbix' /etc/sudoers) > 0 ]]; then
    /bin/sed -i 's@^Cmnd_Alias ZABBIX.*$@Cmnd_Alias ZABBIX = /monitor/service/server-run, /monitor/system/io-all@' /etc/sudoers
fi

cat >> /etc/sudoers << EOF


## Zabbix
Cmnd_Alias ZABBIX = /monitor/service/server-run, /monitor/system/io-all

zabbix ALL = (root) NOPASSWD: ZABBIX
EOF
