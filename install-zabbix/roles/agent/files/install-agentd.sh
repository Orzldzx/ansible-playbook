#!/bin/bash

if [[ ! -d /usr/local/zabbix ]]; then 
    cd /opt/software
    tar xf zabbix-3.4.4.tar.gz
    cd zabbix-3.4.4
    ./configure --prefix=/usr/local/zabbix --enable-agent

    make install
fi
