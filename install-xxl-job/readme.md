# 使用方法

**`ansible-playbook -i <主机列表> -l <主机/组> -t <角色> site.yml`**

> 默认对所有主机执行 playbook  
> -l:   过滤需要执行的主机,如 anhui-jump 只在 `anhui-jump` 主机执行, jump 在 `jump` 组执行.  
> -t:   选择执行的标签, 如 xxl-job-admin 执行 xxl-job-admin 角色的 playbook, 多个用逗号分隔, 如: init,admin  

参数:  
> --list-hosts      查看在哪些主机执行.  
> --list-tags       查看执行哪些角色.  
> -C                检查  

---

例子:

```bash
# 安装调度中心 (所有的跳板机)
ansible-playbook -i ~/ansible/inventory.py -l jump -t init,xxl-job-admin site.yml

# 安装执行器 (安徽区的后端机器, 不建议所有机器一起安装)
ansible-playbook -i ~/ansible/inventory.py -l anhui -t init,xxl-job-agent site.yml
```
