# @Author: seven
# @Date:   2017-12-12T18:06:58+08:00
# @Last modified by:   seven
# @Last modified time: 2017-12-12T18:06:58+08:00



### install zabbix-server

# 安装依赖
yum -y install net-snmp-devel libxml2-devel libcurl-devel libevent libevent-devel libssh2-devel fping

# 解压
cd /opt/download/
tar -xf zabbix-3.4.4.tar.gz -C /opt/software/
cd ../software/zabbix-3.4.4

### 可选功能：
###     --enable-static  #构建静态链接的二进制文件
###     --enable-server  #打开Zabbix服务器的构建
###     --enable-proxy   #打开Zabbix代理的构建
###     --enable-agent   #打开Zabbix代理和客户端实用程序的构建
###     --enable-java    #打开Zabbix支持监控java,zabbix 监控jmx 需要--enable-java
###     --enable-ipv6    #打开zabbix对ipv6的支持
### 可选包：
###     --with-mysql[=ARG]    #使用MySQL客户端库[default = no]，可选指定mysql_config的路径
###     --with-jabber[=DIR]   #包括Jabber支持[default = no]。 DIR是iksemel库安装目录。如果要使用Jabber协议进行消息传递.
###     --with-libxml2[=ARG]  #使用libxml2客户端库[default = no]，可选地指定xml2-config的路径.如果要使用XML库
###     --with-unixodbc[=ARG] #使用ODBC驱动程序对unixODBC包[default = no]，可选地指定odbc_config二进制的完整路径。如果要使用unixODBC库
###     --with-net-snmp[=ARG] #使用Net-SNMP包[default = no]，可选地指定net-snmp-config的路径.如果要使用Net-SNMP库
###     --with-ssh2[=DIR]     #使用SSH2包[default = no]，DIR是SSH2库的安装目录。如果要使用基于SSH2的检查
###     --with-openipmi[=DIR] #包括OPENIPMI支持[default = no]。 DIR是OPENIPMI基本安装目录，默认是通过OPENIPMI文件的一些常见位置进行搜索。如果要检查IPMI设备
###     --with-mbedtls[=DIR]  #使用mbed TLS（PolarSSL）软件包[default = no]，DIR是libpolarssl安装目录。如果要使用由mbed TLS（PolarSSL）库提供的加密
###     --with-gnutls[=DIR]   #使用GnuTLS包[default = no]，DIR是libgnutls的安装目录。如果要使用GnuTLS库提供的加密
###     --with-openssl[=DIR]  #使用OpenSSL包[default = no]，DIR是libssl和libcrypto的安装目录。如果要使用OpenSSL库提供的加密
###     --with-ldap[=DIR]     #包括LDAP支持[default = no]。DIR是LDAP基本安装目录，默认是通过LDAP文件的多个常见位置进行搜索。如果要检查LDAP服务器.
###     --with-libcurl[=DIR]  #使用cURL包[default = no]，可选地指定curl-config的路径.如果要使用cURL库
### 如果要指定iconv安装目录:
###     --with-iconv=[DIR]    #使用iconv从给定的基本安装目录（DIR），默认是通过一些常见的地方搜索iconv文件。
###     --with-iconv-include=[DIR] #使用iconv包含给定路径的头。
###     --with-iconv-lib=[DIR]  #从给定的路径使用iconv库。

./configure --prefix=/usr/local/zabbix \    # 指定安装目录
    --enable-server --enable-agent --with-mysql --enable-ipv6 \
    --with-net-snmp --with-libcurl --with-libxml2 --enable-java --with-ssh2
make && make install

# 添加用户
groupadd zabbix && useradd -r -g zabbix -s /sbin/nologin zabbix

# 授权
chown -R zabbix:zabbix /usr/local/zabbix
mkdir -p  /var/run/zabbix
mkdir -p /var/log/snmptrap
mkdir -p /var/log/zabbix
chown zabbix.zabbix /var/log/snmptrap
chown zabbix.zabbix /var/run/zabbix
chown zabbix.zabbix /var/log/zabbix

# 导入 mysql
mysql -e "create database if not exists zabbix default character set utf8 collate utf8_general_ci;"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zbx123456';"
mysql -e "flush privileges;"

cd database/mysql/
mysql -uzabbix -pzbx123456 zabbix < schema.sql
mysql -uzabbix -pzbx123456 zabbix < images.sql
mysql -uzabbix -pzbx123456 zabbix < data.sql

# init
ln -s /usr/local/zabbix/bin/zabbix_get /usr/local/bin/
ln -s /usr/local/zabbix/bin/zabbix_sender /usr/local/bin/
ln -s /usr/local/zabbix/sbin/zabbix_server /usr/local/sbin/
ln -s /usr/local/zabbix/sbin/zabbix_agentd /usr/local/sbin/

# 日志
mkdir -p /var/log/zabbix/
chown zabbix:zabbix /var/log/zabbix

# start server
/etc/init.d/zabbix_server start
/etc/init.d/zabbix_agentd start

# 安装 web
mkdir -p /data/nginx-data/zabbix
mkdir -p /data/nginx-logs/zabbix

cd /opt/software/zabbix/frontends/php
cp -arf * /data/nginx-data/zabbix/

chown -R www:www /data/nginx-data
chown -R www:www /data/nginx-logs

# 配置 nginx,php
echo



### install zabbix-proxy

# 数据库
yum install sqlite-devel net-snmp-devel libxml2-devel libcurl-devel libevent-devel fping

# 解压编译
cd /opt/software
tar xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4
./configure --prefix=/usr/local/zabbix --enable-proxy --enable-agent --with-sqlite3 --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --enable-java
make && make install

# 创建用户
groupadd zabbix
useradd -g zabbix -s /sbin/nologin -d /usr/local/zabbix zabbix

# 数据库
mkdir -p /data/sqlite
touch zabbix_proxy.db
chown zabbix.zabbix /data/sqlite
sqlite3 /data/sqlite/zabbix_proxy.db < /opt/software/zabbix-3.4.4/database/sqlite3/schema.sql

# 修改配置
mkdir /var/log/zabbix/
chown zabbix.zabbix /var/log/zabbix
mkdir -p /tmp/zabbix && chown zabbix.zabbix /tmp/zabbix

# monitor


# 启动
ln -s /usr/local/zabbix/sbin/zabbix_proxy /usr/local/sbin/
ln -s /usr/local/zabbix/bin/zabbix_get /usr/local/bin/
ln -s /usr/local/zabbix/bin/zabbix_sender /usr/local/bin/

cat > /usr/lib/systemd/system/zabbix_proxy.service << EOF
[Unit]
Description=Zabbix proxy server
Documentation=https://www.zabbix.com/documentation/3.4/zh/manual
After=network.target

[Service]
Type=forking
PIDFile=/tmp/zabbix/zabbix_proxy.pid
ExecStart=/usr/local/sbin/zabbix_proxy
ExecStop=pkill zabbix_proxy
User=zabbix

[Install]
WantedBy=multi-user.target
EOF

systemctl enable zabbix_proxy.service
systemctl start zabbix_proxy.service



### install zabbix agentd

# 解压编译
cd /opt/software
tar xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4
./configure --prefix=/usr/local/zabbix --enable-agent
make install

# 创建用户
groupadd zabbix
useradd -g zabbix -s /sbin/nologin -d /usr/local/zabbix zabbix

# 创建目录
mkdir -p /var/log/zabbix && chown zabbix.zabbix /var/log/zabbix
mkdir -p /tmp/zabbix && chown zabbix.zabbix /tmp/zabbix

# 配置
cat > /usr/local/zabbix/etc/zabbix_agentd.conf << EOF
PidFile=/tmp/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=30
Server=10.31.154.97
ServerActive=10.31.154.97
Hostname=hebei-jump
HostMetadataItem=system.uname
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/
EOF

cat > /usr/local/zabbix/etc/zabbix_agentd.conf.d/Orzldzx.conf << EOF
EnableRemoteCommands=1
#HostnameItem=system.hostname

# ---------------------------------------------------
# 发现服务项
UserParameter=svr.name,sudo /monitor/service/server-run SerName

# 查看内存,cup,交换分区信息   (image)
UserParameter=svr.status[*],sudo /monitor/service/server-run GetValue $1 $2

# 监控服务运行状态  (image)
UserParameter=svr.run[*],sudo /monitor/service/server-run GetStatus $1

# ---------------------------------------------------
# 判断rsync是否运行
UserParameter=rsync.run,/monitor/service/rsync-run

# ---------------------------------------------------
# 判断防火墙是否正常
UserParameter=check.fw,/monitor/net/check-firewall

# ---------------------------------------------------
# 判断DNS是否可用
UserParameter=check.dns,/monitor/net/check-dns

# ---------------------------------------------------
# 检查数据库备份
UserParameter=bak.db.all,/monitor/backup/check-dbs-bak

# ---------------------------------------------------
# 获取服务和数据库占用内存总数,百分比   (image)
UserParameter=used.mem,/monitor/system/used-all-mem

# ---------------------------------------------------
# 发现数据库(mysql,redis,mongo)
UserParameter=db.name,/monitor/service/sql-run SQL

# 监控数据库运行状态
UserParameter=db.status[*],/monitor/service/sql-run GetStatus $1 $2

# 监控从库状态
UserParameter=db.slave[*],/monitor/service/sql-run Slave $1 $2

# ---------------------------------------------------
# 监控服务配置文件备份状态
UserParameter=bak.svr,/monitor/backup/check-svr-bak check

# ---------------------------------------------------
# 发现磁盘
UserParameter=sudo disk.name,/monitor/system/io-all DISK

# 监控磁盘繁忙度        (image)
UserParameter=sudo disk.io.use[*],/monitor/system/io-all USE $1

# 监控磁盘读            (image) 图用{#DISKNAME}
UserParameter=sudo disk.io.read[*],/monitor/system/io-all READ $1

# 监控磁盘写            (image) 3个在一张图
UserParameter=sudo disk.io.write[*],/monitor/system/io-all WRITE $1

# 监控磁盘是否可写
UserParameter=disk.io.nowrite[*],/monitor/system/io-all CHECK $1

# ---------------------------------------------------
# 对比时间
UserParameter=sys.time,/monitor/system/sys-time -H ntp1.cloud.aliyuncs.com -w 0.5|grep -wc OK

# ---------------------------------------------------
# 监控tcp状态
UserParameter=net.tcp.status[*],/monitor/net/check-tcp-status $1
EOF

cp monitor-dir

# sudo
sed -i 's/^Defaults    requiretty/# Defaults    requiretty/' /etc/sudoers
if [[ $(grep -c 'visiblepw' /etc/sudoers) > 0 ]]; then
    var=$(grep -n 'visiblepw' /etc/sudoers)
    line=${var#*:}
    sed -i "s/$line/# $line/" /etc/sudoers
    sed -i "/$line/a\Defaults   visiblepw" /etc/sudoers
fi

cat >> /etc/sudoers << EOF


## Zabbix
Cmnd_Alias ZABBIX = /monitor/service/server-run, /monitor/service/sql-run

zabbix ALL = (root) NOPASSWD: ZABBIX
EOF

# swap
if [[ $(swapon -s| wc -l) == 0 ]]; then
    cd /opt/
    dd if=/dev/zero of=swap1.file bs=1M count=4096
    mkswap swap1.file
    chmod 0600 swap1.file
    swapon swap1.file
    echo '/opt/swap1.file    swap    swap    defaults    0 0' >> /etc/fstab
fi

# 启动
ln -s /usr/local/zabbix/sbin/zabbix_agentd /usr/local/sbin/
ln -s /usr/local/zabbix/bin/zabbix_get /usr/local/bin/
ln -s /usr/local/zabbix/bin/zabbix_sender /usr/local/bin/

# systemctl
cat > /usr/lib/systemd/system/zabbix_agentd.service << EOF
[Unit]
Description=Zabbix agent
Documentation=https://www.zabbix.com/documentation/3.4/zh/manual
After=network.target

[Service]
Type=forking
PIDFile=/tmp/zabbix/zabbix_agentd.pid
ExecStart=/usr/local/sbin/zabbix_agentd
ExecStop=pkill zabbix_agentd
User=zabbix

[Install]
WantedBy=multi-user.target
EOF

systemctl enable zabbix_agentd.service
systemctl start zabbix_agentd.service
