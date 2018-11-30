# 自用节点主机使用脚本

* 适用于Linux系统

# 脚本介绍：

* init-vps.sh           系统初始化主脚本(1)
* install_libsodium.sh  安装libsodium的脚本，会被init-vps.sh远程调用

# (1)系统初始化脚本使用方法

* 在目标机器上执行以下命令：
```bash
curl -SL https://raw.githubusercontent.com/MxdStudio/scripts/master/01.Common/init-vps.sh | bash -s -- 主机子域名 主机内存数(M)

eg:
curl -SL https://raw.githubusercontent.com/MxdStudio/scripts/master/01.Common/init-vps.sh | bash -s -- www 512
```