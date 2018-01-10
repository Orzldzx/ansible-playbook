#!/bin/bash

cd /opt/software
tar xf zabbix-3.4.4.tar.gz

cd zabbix-3.4.4
java --version
if [[ $? -eq 0 ]]; then
    ./configure --prefix=/usr/local/zabbix --enable-proxy --enable-agent --with-sqlite3 --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --enable-java
else
    ./configure --prefix=/usr/local/zabbix --enable-proxy --enable-agent --with-sqlite3 --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
fi

make install
