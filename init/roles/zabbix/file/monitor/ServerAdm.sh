#!/bin/bash
# 1un
# 2016-01-28 --update
# 整合服务启动/停止/重启/重载功能

#变量
export LD_LIBRARY_PATH=/svndata/svr/lib/3rd/mongodb
export LUA_PATH=/svndata/svr/config/luascripts/?.lua
export LUA_CPATH=/svndata/svr/config/luascripts/?.so';'/usr/lib/x86_64-linux-gnu/lua/5.1/?.so

Mod=/svndata/svr/mod.txt
Ptype=

#调整打开文件限制,调整虚拟内存大小限制
ulimit -c unlimited
ulimit -SHn 65535
sysctl -w kernel.shmmax=4000000000  > /dev/null

#帮助
Help(){
    echo "Usage: ${0} [start|stop|restart|reload|status] [all|ServerName]"
    exit
}

#打印信息
Print(){
    if [ $? -eq 0 ]; then
        if [[ $Ptype -eq 1 ]]; then
                printf " %-30s %-7s Succeed\n" "[ ${1} ]" ${2}
        elif [[ $Ptype -eq 2 ]]; then
                printf " %-30s running %-12s\n" "[ ${1} ]" ${2}
        fi
    else
        if [[ $Ptype -eq 1 ]]; then
            printf " %-30s %-7s Failed\n" "[ ${1} ]" ${2}
        elif [[ $Ptype -eq 2 ]]; then
            printf " %-30s down    %-12s\n" "[ ${1} ]" ${2}
        fi
    fi
}

#清理共享内存
ClearShm(){
    for id in $(ipcs -m|awk '{if($6 == 0){print $2}}')
    do
        ipcrm -m $id
    done
}

#启动服务
Start(){
    local Ptype=1
    if [[ $(pgrep ${1}|wc -l) = 1 ]]; then
        printf " %-30s %-7s\n" "[ ${1} ]" "already running!"
    else
        Type=$(echo ${1}|grep tcpsvrd|wc -l)
        if [[ ${Type} -eq 1 ]]; then
            cd /svndata/svr/${1}/bin && ./start_tcpsvrd.sh &> /dev/null
        else
            cd /svndata/svr/${1}/bin && ./${1} &> /dev/null
        fi
        sleep 8
        pgrep ${1} &> /dev/null
        Print ${1} start
    fi
}

#停止服务
Stop(){
    local Ptype=1
    pkill -9 ${1:0:15}
    sleep 0.5
    [[ $(pgrep ${1:0:15}|wc -l) -eq 0 ]] || pkill -9 ${1:0:15}
    Print ${1} stop
}

#重载服务
Reload(){
    local Ptype=1
    sleep 0.3
    pkill -USR1 ${1:0:15}
    Print ${1} reload
}

#查看状态
Status(){
    local Ptype=2
    for Ps in ${1}
    do
        Time=$(ps -o comm,etime -p $(pgrep ${Ps}) 2>/dev/null|grep -v COMMAND|awk '{print $2}')
        pgrep ${Ps} > /dev/null
        Print ${Ps} ${Time}
    done
}

#选择
Case(){
    case ${1} in
        start)
            Start ${2} ;;
        stop)
            Stop ${2}
            sleep 0.5
            ClearShm
            ;;
        reload)
            Reload ${2} ;;
        status)
            Status ${2} ;;
        *)
           Help ;;
    esac
}

# stop autorestart
[[ ${1} = stop || ${1} = "restart" ]] && { pkill -9 autorestart ; sleep 0.5 ; }

#检测参数是否正确
[ $# -ne 2 ] && Help

#main
if [[ ${2} = "all" ]]; then
    if [[ ${1} = "restart" ]]; then
        for Ser in $(awk '{print $1}' $Mod); do
            Case stop ${Ser}
        done
        echo -e "   -+-+- "
        for Ser in $(awk '{print $1}' $Mod); do
            Case start ${Ser}
        done
    else
        for Ser in $(awk '{print $1}' $Mod); do
            Case ${1} ${Ser}
        done
    fi
else
    if [[ $(grep ${2} $Mod|wc -l) -ge 1 ]]; then
        if [[ ${1} = "restart" ]]; then
            Case stop ${2}
            Case start ${2}
        else
            Case ${1} ${2}
        fi
    else
         echo " [ ${2} ] not found"
    fi
fi

# start autorestart
if [[ ${1} = "start" || ${1} = "restart" ]]; then
    if [ $(pgrep autorestart|wc -l) -lt 1 ]; then
        sleep 0.2
        cd /svndata/svr/autorestart/bin
        ./autorestart &> /dev/null
    fi
fi
