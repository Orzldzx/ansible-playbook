#!/bin/bash

# 准备
groupadd zabbix && useradd -g zabbix zabbix -s /bin/false
cat >> /etc/sudoers << EOF
zabbix ALL=(ALL) NOPASSWD:/sbin/pvdisplay
zabbix ALL=(ALL) NOPASSWD:/sbin/lvdisplay
zabbix ALL=(ALL) NOPASSWD:/bin/mkdir
zabbix ALL=(ALL) NOPASSWD:/bin/chmod
EOF

tar xf /tmp/zabbix-2.4.6.tar.gz -C /opt/
cd /opt/zabbix-2.4.6

# 安装
./configure --prefix=/opt/zabbix-2.4.6 --enable-agent
make install

# 配置
chmod -R +x /monitor
echo 'PATH=${PATH}:/opt/zabbix-2.4.6/sbin' >> /root/.bashrc

mkdir -p /etc/zabbix/zabbix_agentd.d && chown zabbix:zabbix /etc/zabbix/zabbix_agentd.d
mkdir -p /var/log/zabbix && chown zabbix:zabbix /var/log/zabbix
mkdir -p /var/run/zabbix && chown zabbix:zabbix /var/run/zabbix

