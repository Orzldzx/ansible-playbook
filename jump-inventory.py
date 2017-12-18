#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: seven
# @Date:   2017-10-24T16:15:28+08:00
# @Last modified by:   seven
# @Last modified time: 2017-12-18T16:17:25+08:00


'''
CMDB(jumpserver) custom dynamic inventory script for Ansible, in Python.
'''


import os
import sys
import MySQLdb
from pprint import pprint
from Crypto.Cipher import AES
from binascii import b2a_hex, a2b_hex
import argparse

try:
    import json
except ImportError:
    import simplejson as json


class PyCrypt(object):
    """
    This class used to encrypt and decrypt password.
    加密类
    """

    def __init__(self, key):
        self.key = key
        self.mode = AES.MODE_CBC

    @staticmethod
    def gen_rand_pass(length=16, especial=False):
        """
        random password
        随机生成密码
        """
        salt_key = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'
        symbol = '!@$%^&*()_'
        salt_list = []
        if especial:
            for i in range(length - 4):
                salt_list.append(random.choice(salt_key))
            for i in range(4):
                salt_list.append(random.choice(symbol))
        else:
            for i in range(length):
                salt_list.append(random.choice(salt_key))
        salt = ''.join(salt_list)
        return salt

    @staticmethod
    def md5_crypt(string):
        """
        md5 encrypt method
        md5非对称加密方法
        """
        return hashlib.new("md5", string).hexdigest()

    @staticmethod
    def gen_sha512(salt, password):
        """
        generate sha512 format password
        生成sha512加密密码
        """
        return crypt.crypt(password, '$6$%s$' % salt)

    def encrypt(self, passwd=None, length=32):
        """
        encrypt gen password
        对称加密之加密生成密码
        """
        if not passwd:
            passwd = self.gen_rand_pass()

        cryptor = AES.new(self.key, self.mode, b'8122ca7d906ad5e1')
        try:
            count = len(passwd)
        except TypeError:
            raise ServerError('Encrypt password error, TYpe error.')

        add = (length - (count % length))
        passwd += ('\0' * add)
        cipher_text = cryptor.encrypt(passwd)
        return b2a_hex(cipher_text)

    def decrypt(self, text):
        """
        decrypt pass base the same key
        对称加密之解密，同一个加密随机数
        """
        cryptor = AES.new(self.key, self.mode, b'8122ca7d906ad5e1')
        try:
            plain_text = cryptor.decrypt(a2b_hex(text))
        except TypeError:
            raise ServerError('Decrypt password error, TYpe error.')
        return plain_text.rstrip('\0')


class ConnectMySqlDB(object):

    def __init__(self, dbhost, dbport, dbuser, dbpass, database, charset=None):
        self.dbhost = dbhost
        self.dbport = dbport
        self.dbuser = dbuser
        self.dbpass = dbpass
        self.database = database
        self.charset = 'utf8mb4' if not charset else charset

        self.conn = self.connect_mysql()

    def connect_mysql(self):
        try:
            connection = MySQLdb.connect(host = self.dbhost, port = self.dbport,
                            user = self.dbuser, passwd = self.dbpass,
                            db = self.database, charset = self.charset)
        except MySQLdb.Error as e:
            print("Mysql Error {0}: {1}".format(e.args[0], e.args[1]))
        return connection

    def close_mysql(self):
        self.conn.close()

    def get_data(self, sql=None):
        if sql is None:
            self.close_mysql()
            print("SQL syntax: {0}".format(sql))
            return {'_meta': {'hostvars': {}}}

        cur = self.conn.cursor()
        try:
            cur.execute(sql)
            result = cur.fetchall()
        except MySQLdb.Error as e:
            print("Mysql select Error {0}: {1}".format(e.args[0], e.args[1]))

        cur.close()
        return result


class MyInventory(object):

    def __init__(self, hostinfo, defkey):
        self.hostinfo = hostinfo
        self.defkey = defkey
        self.hosts = {}
        self.hosts['_meta'] = dict(hostvars=dict())
        self.inventory = {}
        self.read_cli_args()

        # `--list` 调用.
        if self.args.list:
            self.inventory = self.get_inventory()
        # `--host [hostname]` 调用.
        elif self.args.host:
            # 返回空, 在执行 `--list` 是会返回 _meta
            self.inventory = self.empty_inventory()
        # 如果没有参数, 返回空
        else:
            self.inventory = self.empty_inventory()

        print(json.dumps(self.inventory))

    # 获取主机列表.
    def get_inventory(self):
        def_user = self.defkey[0][2]
        def_key = self.defkey[0][5]
        for host in hostinfo:
            host_name = host[4]
            host_group = host[1]
            host_ip = host[3]
            host_port = host[5]
            host_user = host[6]
            host_pass = host[7]
            host_default_auth = host[8]
            host_other_ip = host[9]

            if self.hosts.get(host_group):
                if not host_name in self.hosts[host_group]['hosts']:
                    self.hosts[host_group]['hosts'].append(host_name)
            else:
                self.hosts[host_group] = dict(hosts = [ host_name ], vars = dict())

            host_vars = self.hosts['_meta']['hostvars']
            if not host_vars.get(host_name):
                if host_default_auth == 1:
                    host_vars[host_name] = dict(
                        ansible_ssh_host = host_ip,
                        ansible_ssh_port = host_port,
                        ansible_ssh_user = def_user,
                        ansible_ssh_private_key_file = def_key,
                        other_ip = host_other_ip)
                elif host_default_auth == 0:
                    #print host_name, host_ip, host_port, host_user, host_pass, host_default_auth
                    KEY = 'b0s0s868sr0ha2ix'
                    CRYPT = PyCrypt(KEY)
                    host_vars[host_name] = dict(
                        ansible_ssh_host = host_ip,
                        ansible_ssh_port = host_port,
                        ansible_ssh_user = host_user,
                        ansible_ssh_pass = CRYPT.decrypt(host_pass),
                        other_ip = host_other_ip)
                else:
                    pass
        return self.hosts

    # 返回空列表.
    def empty_inventory(self):
        return {'_meta': {'hostvars': {}}}

    # 读取命令行参数传递给脚本.
    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action = 'store_true')
        parser.add_argument('--host', action = 'store')
        self.args = parser.parse_args()


# 获取主机列表.
if __name__ == '__main__':
    c1 = ConnectMySqlDB(dbhost='127.0.0.1', dbport=3306, dbuser='jump', dbpass='', database='jumpserver', charset='utf8mb4')
    sql = '''
        SELECT jasset_asset_group.assetgroup_id AS group_id, jasset_assetgroup.name AS group_name,
        jasset_asset_group.asset_id, jasset_asset.ip, jasset_asset.hostname, jasset_asset.port,
        jasset_asset.username, jasset_asset.password, jasset_asset.use_default_auth, jasset_asset.other_ip
        FROM jasset_asset_group
        LEFT JOIN jasset_asset ON jasset_asset_group.asset_id = jasset_asset.id
        LEFT JOIN jasset_assetgroup ON jasset_asset_group.assetgroup_id = jasset_assetgroup.id;
    '''
    hostinfo = c1.get_data(sql)

    sql = 'select * from setting;'
    defkey = c1.get_data(sql)
    c1.close_mysql()

    MyInventory(hostinfo, defkey)

'''
resource = {
    'anhui-gamesvrd': {
        'hosts': [ 'anhui-bf-1', 'anhui-bf-2' ],
        'vars': {
            'ansible_ssh_host': 'xxx.55.xx.67',
            'ansible_ssh_user': 'root',
            'ansible_ssh_private_key_file': '/xxx/user.pem'
        }
    },
    'hebei-gamesvrd': {
        'hosts': [ 'hebei-bf-1', 'hebei-bf-2' ],
        'vars': {
            'ansible_ssh_user': 'root',
            'ansible_ssh_host': 'xx.xxx.125.10',
            'ansible_ssh_private_key_file': '/xxx/user.pem'
        }
    },
    '_meta': {
        'hostvars': {
            'anhui-bf-1': {
                'ansible_ssh_port': 46801
            },
            'anhui-bf-2': {
                'ansible_ssh_port': 46802
            },
            'hebei-bf-1': {
                'ansible_ssh_port': 15901
            },
            'hebei-bf-2': {
                'ansible_ssh_port': 15902
            }
        }
    }
}
'''
