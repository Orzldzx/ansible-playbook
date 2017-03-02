#!/usr/bin/env python
# -*- coding: utf-8
# 1un
# 2016-11-08
# Ansible Version >=2.0

import yaml
import json
import os
import sys
from ansible.parsing.dataloader import DataLoader
from ansible.vars import VariableManager
from ansible.inventory import Inventory
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.plugins.callback import CallbackBase

service_list_file = '/push/conf/config-services.yml'
loader = DataLoader()
variable_manager = VariableManager()
inventory = Inventory(loader=loader, variable_manager=variable_manager)
variable_manager.set_inventory(inventory)


def yaml_load(filename):

    with open(filename, 'rb') as f:
        service_lists = yaml.load(f)
    return service_lists


def get_srvlist(service_lists):

    __service_lists = yaml_load(service_list_file)
    service_list = {}

    for service_type in __service_lists:
        for service_names in __service_lists[service_type]:
            for service_num in range(0, len(__service_lists[service_type][service_names])):
                service_name = '{0}.{1}'.format(service_names, service_num + 1)
                service_option = __service_lists[service_type][service_names][service_num]
                service_list.setdefault(service_names)
                if not isinstance(service_list[service_names], list):
                    service_list[service_names] = []
                service_list[service_names].append(
                    {'name': service_name, 'ip': service_option['lip']})
    return service_list


class Options(object):

    def __init__(self):
        self.connection = "local"
        self.forks = 1
        self.check = False

    def __getattr__(self, name):
        return None

options = Options()


class ResultCallback(CallbackBase):

    def v2_runner_on_ok(self, result, **kwargs):
        host = result._host
        print json.dumps({host.name: result._result}, indent=4)

results_callback = ResultCallback()


def runner(name, host, command):

    play_source = {"name": "Ansible Ad-Hoc",
                   "hosts": host,
                   "gather_facts": "no",
                   "tasks":
                       [
                           {
                               "action": {
                                   "module": "raw",
                                   "args": command,
                               },
                               "register": "shell_out",
                               "name": " Restart %s" % name,
                           },
                       ]
                   }
    play = Play().load(play_source, variable_manager=variable_manager, loader=loader)
    tqm = None
    try:
        tqm = TaskQueueManager(
            inventory=inventory,
            variable_manager=variable_manager,
            loader=loader,
            options=options,
            passwords=None,
            # stdout_callback=results_callback,
            run_tree=False,
        )
        result = tqm.run(play)
#        print result
    finally:
        if tqm is not None:
            tqm.cleanup()

if __name__ == '__main__':
    SERVICE_STATE_TYPE = ["restart", "reload"]

    service_state = sys.argv[1]
    if not service_state in SERVICE_STATE_TYPE:
        print "暂未支持此类型变更: %s" % service_state
        sys.exit(1)

    service = sys.argv[2].split('.')[0]
    service_name = sys.argv[2]
    #service_num = sys.argv[2].split('.')[1]

    services = get_srvlist(service_list_file)


    if service is 'all':
        for __service in services:
            host = __service['ip']
            serviceName = __service['name']
            print "-----"
            os.system("ansible %s -m raw -a 'supervisorctl %s %s'" %
                      (host, service_state, serviceName))
            print "---"
            os.system("ansible %s -m raw -a 'supervisorctl status' |grep %s" %
                      (host, serviceName))
            print "----------\n"
    elif service in services:
        for __service in services[service]:
            if service_name == __service['name']:
                host = __service['ip']
                command = '/local/bin/supervisorctl %s %s' % (service_state, service_name)
                print "-----"
                #runner(service_name, host, command)
                os.system("ansible %s -m raw -a 'supervisorctl %s %s'" %
                          (host, service_state, service_name))
                print "---"
                os.system("ansible %s -m raw -a 'supervisorctl status' |grep %s" %
                          (host, service_name))
                print "----------\n"
