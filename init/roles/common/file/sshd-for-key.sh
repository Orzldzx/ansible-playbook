#!/bin/bash
# 1un
# 2015-10-09
# for ubuntu

wanip=$(cat /etc/wan)
SSHD_CONFIG_FILE=/etc/ssh/sshd_config
# Func
# Func 1
RETURN_CODE=0
#*号用的好，0个或者无限个，匹配的很全面
#REURNCODE 定义在函数之外，稍有变动都会迭代的影响
#他是用来判断是否执行顺利！
#
#注意 sed -i 后面是双引号！ 引入的$1 和 $* 两大位置变量
#sed 的作用是，不管有没有#注释掉这个参数，都把其置为$*后的参数
#这中写法需要参数全带
sshd_config() {
    # Syntax: sshd_config <option> <value>
    egrep "^ *$1" ${SSHD_CONFIG_FILE} > /dev/null
    if [ $? -eq 0 ];then
        sed -i "/^ *$1.*/s#.*#$*#" ${SSHD_CONFIG_FILE}
        #let RETURN_CODE=${RETURN_CODE}+$?
    else
        sed -i "/^# *$1.*/s#.*#$*#" ${SSHD_CONFIG_FILE}
        #let RETURN_CODE=${RETURN_CODE}+$?
    fi
}

#修改配置项
sshd_config Port 13021
sshd_config Protocol 2
sshd_config UseDNS no
sshd_config PubkeyAuthentication yes
sshd_config AuthorizedKeysFile .ssh/authorized_keys
#允许密码认证登入，调试完后关闭
sshd_config PasswordAuthentication no
#sshd_config PasswordAuthentication yes
sshd_config MaxAuthTries 60
#sshd_config PermitRootLogin no

[ ${RETURN_CODE} -eq 0 ] && echo “Change sshd is ok!!!” || exit 1

/etc/init.d/ssh restart

