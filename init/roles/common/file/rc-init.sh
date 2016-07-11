#!/bin/bash

sed -i "/rsync/d" /etc/rc.local
sed -i "/iptables/d" /etc/rc.local
sed -i "/exit/d" /etc/rc.local

echo "/usr/bin/rsync --daemon" >> /etc/rc.local
echo "/fw/iptables start" >> /etc/rc.local
echo "/etc/init.d/zabbix-agent start" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
