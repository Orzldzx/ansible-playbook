#!/bin/bash

ARGS=2
if [ $# -ne "$ARGS" ]; then
    echo "Please input one arguement:" 
fi
 
if [[ $1 -eq "3306" ]]; then
    MYSQL_SOCK=$(cat /etc/mysql/my.cnf |grep -wi sock |sort |uniq -c |awk '{print $NF}')
else
    MYSQL_SOCK=$(cat /etc/mysql/my${1}.cnf |grep -wi sock |sort |uniq -c |awk '{print $NF}')
fi
MYSQL_PWD="XimiMsat19292014"

case $2 in
    Version)
        result=$(mysql -S $MYSQL_SOCK -V 2>/dev/null |cut -f1 -d",")
        echo $result
        ;;
    Ping)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK ping 2>/dev/null |grep -c alive)
        echo $result
        ;;
    Uptime)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK status 2>/dev/null |cut -f2 -d":" |cut -f1 -d"T")
        echo $result 
        ;; 
    Process)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK processlist 2>/dev/null |grep "^| [0-9]" |wc -l)
        echo $result
        ;;
    Com_update)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_update" |cut -d"|" -f3)
        echo $result
        ;;
    Slow_queries)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK status 2>/dev/null |cut -f5 -d":" |cut -f1 -d"O")
        echo $result 
        ;; 
    Com_select)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_select" |cut -d"|" -f3)
        echo $result
        ;;
    Com_rollback)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_rollback" |cut -d"|" -f3)
        echo $result
        ;;
    Questions)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK status 2>/dev/null |cut -f4 -d":" |cut -f1 -d"S")
        echo $result
        ;;
    Com_insert)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_insert" |cut -d"|" -f3)
        echo $result
        ;;
    Com_delete)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_delete" |cut -d"|" -f3)
        echo $result
        ;;
    Com_commit)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_commit" |cut -d"|" -f3)
        echo $result
        ;;
    Bytes_sent)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Bytes_sent" |cut -d"|" -f3)
        echo $result
        ;;
    Bytes_received)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Bytes_received" |cut -d"|" -f3)
        echo $result
        ;;
    Com_begin)
        result=$(mysqladmin -uroot -p${MYSQL_PWD} -S $MYSQL_SOCK extended-status 2>/dev/null |grep -w "Com_begin" |cut -d"|" -f3)
        echo $result
        ;;
    *) echo "  Usage: $0 MYSQL_PORT [Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions]" ;; 
esac
