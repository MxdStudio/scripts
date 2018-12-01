# ServerStatus宿主机列表 - serverstatus.list

* 用于被监控的节点主机自动生成ServerStatus客户端执行的Supervisor配置文件
* 格式
```bash
宿主机子域名=宿主机IP
每个宿主机的信息间换行

eg:
www1=111.222.333.444
www2=222.333.444.555
```

# 主机初始化域名后缀 - domain-suffix

* 用于主机初始化脚本设置hostname
* 只读取第一行内容