#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 1un
# 2016-01-28

'''
    实现启动/停止/重载/重启各个项目服务端程序
'''

import yaml         
import sys
import paramiko     
import urllib
import urllib2
import requests     


# SSH connection parameters
port = 13021                                            
user = 'root'                                          
keyfile = '/root/.ssh/id_rsa'                          
cmd = '/svndata/svr/ServerAdm.sh'                      
key = paramiko.RSAKey.from_private_key_file(keyfile)   
ssh = paramiko.SSHClient()                             

# def service list, all ip, all type, all service name, all service number
srv = {}                
all_ipaddr = []         
all_change_type = []    
all_service_name = []    
all_service_num = []    

# ---------------------

try:
    # Get service list file address
    url = 'http://120.92.226.38/xyj/auto-push/%s/deploy.cfg' %sys.argv[1]
except IndexError:
    Help()

print "下载服务列表文件"
urllib.urlretrieve(url, "list.txt")


# Import service list info srv dict
with open('list.txt') as f:
    for line in f.readlines():
        l = line.split()
        if l[0][0] != '#':
            print l
            if l[1] in srv:
                num = len(srv[l[1]])
                srv[l[1]].append([l[3], srv[l[1]][num - 1][1] + 1])
            else:
                srv[l[1]]=[[l[3], 1]]

# Import task type and service name into service dict
with open('srv.yml') as f:
    service = yaml.load(f)

# ---------------------

def Help():
    print '''
    Usage: %s 项目 操作类型
          ''' % sys.argv[0]

def change_srv():

    '''
        获得需要操作的服务名和操作类型.
    '''

    if sys.argv[2] in service.keys():
        for srv_name in service[sys.argv[2]]:
            if srv_name in srv.keys():
                for srv_num in range(len(srv[srv_name])):
                    get_parameter_list(srv[srv_name][srv_num][0], sys.argv[2], srv_name, srv[srv_name][srv_num][1])
            elif '.' in srv_name:
                _srv_name = srv_name.split('.')[0]
                _srv_num = int(srv_name.split('.')[1])
                get_parameter_list(srv[_srv_name][_srv_num -1][0], sys.argv[2], _srv_name, _srv_num)
            elif srv_name == 'all':
                for all_srv_name in srv.keys():
                    for all_srv_num in range(len(srv[all_srv_name])):
                        get_parameter_list(srv[all_srv_name][all_srv_num][0], sys.argv[2], all_srv_name, srv[all_srv_name][all_srv_num][1])
            else:
                print '\033[31mNot found:', srv_name, '\033[0m'
    else:
        print '\033[31mNot found:', sys.argv[2], '\033[0m'

def get_parameter_list(_ipaddr, _change_type, _service_name, _service_num):

    '''
        把参数传到列表
    '''

    global all_ipaddr, all_change_type, all_service_name, all_service_num
    all_ipaddr.append(_ipaddr)
    all_change_type.append(_change_type)
    all_service_name.append(_service_name)
    all_service_num.append(_service_num)

def connect_to_srv(ip, ty, na, nu):

    '''
        连接远端服务器执行命令,打印返回值
    '''

    host = ip
    ssh.load_system_host_keys()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, user, key)
    print "\033[32m>>> %s --- shell | %s %s.%d\033[0m" %(ip, ty, na, nu)
    stdin,stdout,stderr = ssh.exec_command('%s %s %s.%d' %(cmd, ty, na, nu))
    print stdout.read(), stderr.read()
    ssh.close()

def main():

#    # Download list file
#    wget_srv_list()

    # Check list file
    # 不想加了

    # Get task type and service name
    change_srv()

    # Run on the specified server
    for (ip, ty, na, nu) in zip(all_ipaddr, all_change_type, all_service_name, all_service_num):
        connect_to_srv(ip, ty, na, nu)

if __name__ == '__main__':
    if len(sys.argv[1:]) == 2:
        main()
    else:
        Help()
