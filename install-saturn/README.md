# 简介

批量部署 Saturn 控制台和执行器


# 使用

## 部署控制台

`ansible-playbook site.yml -l jump -t console`  

> 在 `jump` 主机组部署 `Saturn-console`  

## 部署执行器

`ansible-playbook site.yml -l anhui:heb -t executor`  

> 在 `安徽` 和 `河北` 组部署 `Saturn-execute`  

---

```
ansible-playbook
    option:
        -v                  显示详细信息
        -C, --check         检查 playbook 流程, 不是真的执行.
        --list-hosts        查看执行的主机
        --list-tasks        查看执行的任务
        --list-tags         查看执行的标签
```

---

> 部署完成需要到控制台添加需要管理的zk域.  
>> http://<Domain name/ip>:9088/system_config
>> CONSOLE_ZK_CLUSTER_MAPPING = default:/<zk-name>


# 说明

## 通用

- 安装 jdk8

## Saturn-console

1. 添加 zookeeper 账户
2. 创建相关目录
3. 安装 zookeeper
4. 启动 zookeeper
5. 安装 Saturn-console
6. 添加 zookeeper 信息到 mysql
7. 启动 Saturn-console

## Saturn-execute

1. 修改 `/etc/hosts` (域名映射到跳板机内网地址)
2. 创建相关目录
3. 安装 Saturn-execute
4. 修改 Saturn-execute 配置
5. 启动 Saturn-execute

