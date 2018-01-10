# 定义变量

在 group_vars 目录里创建一个和主机组同名的文件添加 proxy_zone 和 zabbix_proxy 变量

例:

```python
proxy_zone: anhui           # 这里定义proxy的名称   (proxy会用到)
zabbix_proxy: 127.0.0.1     # 这里定义proxy的IP地址 (agent会用到)
```


# 测试

```
# 测试,不是真正的执行(可以检查是否有问题)
ansible-playbook proxy.yml --extra-vars "{'hosts': '<hostname>'}" -C
```


# 安装 zabbix-proxy

```
ansible-playbook proxy.yml --extra-vars "hosts=<hostname>"

# 所有跳板机安装 proxy
ansible-playbook proxy.yml -e "hosts=jump"
```


# 安装 zabbix-agent

```
ansible-playbook agent.yml -e "hosts=<hostname>"

# 安徽组所有主机安装 agent
ansible-playbook agent.yml -e "hosts=anhui"
```


# 网页操作

1. 添加 agent 代理

```
管理 => agent代理程序 => 创建代理

---

agent代理程序名称 = Zabbix-anhui-proxy          # anhui 是上面定义变量 proxy_zone 的值
```


2. 添加自动发现规则

```
配置 => 动作 => 自动注册 => 创建动作

---

名称 = <随便取个名字>
添加新的触发条件:
    主机元数据     like Linux
    主机名称       like anhui
    agent代理程序  等于 Zabbix-anhui-proxy
添加新的操作:
    添加到主机群组 等于 河南区
    链接到模板     等于 Template OS Linux
```

