# iniplay

ansible-playbook


# 简介

## initialize the ubuntu system

__初始化功能playbook__ --- `init`

### 基础设置
创建用户, 初始化磁盘, 创建工作目录, 配置环境变量, 更新软件源仓库, 安装软件, 安装jdk, 配置防火墙, 安全加固, 配置DNS, 配置启动项, 配置ssh服务, 增加swap, ubuntu启动不清除tmp目录, 内核参数优化, 清理临时文件
### 部署mongodb
自动匹配部署主从数据库

### 部署mysqldb
自动匹配部署主从数据库

### 部署redisdb
自动匹配部署主从数据库

### 部署zabbix客户端
安装zabbix客户端, 导入配置文件, 导入监控脚本, 启动服务

# 使用方法

1. 修改 `group_vars/all` 里相关变量
2. 修改 `hosts` 相关变量
3. 上传 `ssh-key` 文件
4. 上传 `java-jdk` 软件包
5. 视情况注释 磁盘格式化 和 java 安装
