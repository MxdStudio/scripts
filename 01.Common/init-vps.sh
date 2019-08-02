#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
sleep 5

#=================================================
#   System Required: CentOS 6+
#   Description: Init VPS for myself
#   Version: 1.0
#   Author: MxdStudio
#=================================================

#判断相关文件是否已上传
if [ ! -d "/root/mxd-repo" ]; then
    echo "相关配置库未上传, 请先上传配置库再执行本脚本 !!!";
    exit 1;
else
    echo "监测到相关配置库已上传, 开始执行脚本 ...";
fi
echo " "
echo "************************************************"
echo "* -------------------------------------------- *"
echo "* | MxdStudio自用VPS初始化脚本               | *"
echo "* |   --- 本脚本只适用于CentOS 6 和 7        | *"
echo "* | 作者: MxdStudio                          | *"
echo "* -------------------------------------------- *"
echo "************************************************"
echo " "

############
# 公共变量 #
############
domain=""
subdomain=""
fulldomain=""

#检查Root权限
echo " "
echo "开始检查ROOT权限 ..."
[ $(id -u) != "0" ] && { echo " 必须以Root身份执行本脚本!"; exit 1; }
echo " "
echo "#############################################"
echo "ROOT权限检查OK !"
echo "#############################################"


#检查Linux分支,是否为CentOS
echo " "
echo "开始检查Linux分支 ..."
if [ -f /etc/redhat-release ];then
        OS='CentOS'
#    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
#        OS='Debian'
#    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
#        OS='Ubuntu'
    else
        echo " 本脚本只支持CentOS, 不支持当前系统, 请重新安装系统或重试!"
        exit 1
fi
echo " "
echo "#############################################"
echo "检查Linux分支OK !"
echo "#############################################"

##检查CentOS版本
#echo " "
#echo "开始检查CentOS版本 ..."
#rpm -q centos-release|cut -d- -f3
#s_centos_ver=`rpm -q centos-release|cut -d- -f3`
#if [ $s_centos_ver -eq "6" -o $s_centos_ver -eq "7" ];then
#        echo "..."
#    else
#        echo " 本脚本只支持CentOS 6 和 7, 不支持当前版本 ${s_centos_ver} , 请重新安装系统或重试!"
#        exit 1
#fi
#echo " "
#echo "#############################################"
#echo "检查CentOS版本OK !"
#echo "#############################################"
#

#nofile计算
echo " "
echo "开始计算nofile值 ..."
nofile=$(expr $2 / 4 \* 256)
echo " "
echo "#############################################"
echo "nofile计算结果为 ${nofile}"
echo "#############################################"

#设置主机名
echo " "
echo "开始设置主机名及本机HOST ..."
hostnamectl --transient set-hostname ${fulldomain}
hostnamectl --pretty set-hostname ${fulldomain}
hostnamectl --static set-hostname ${fulldomain}
echo "${fulldomain}" > /etc/hostname
echo " "
echo "#############################################"
echo "设置主机名及本机HOST完成 !"
hostname
echo "#############################################"

#设置字符集为UTF8
echo " "
echo "开始设置语言及字符集 ..."
#vi /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "
export LC_ALL=en_US.UTF-8" >> /root/.bash_profile
export LC_ALL=en_US.UTF-8
echo " "
echo "#############################################"
echo "设置语言及字符集完成 ! 结果如下显示:"
echo "#############################################"
locale
#locale -a | grep zh_*

#安装cjk字体
#yum groupinstall chinese-support
#yum groupinstall japanese-support
#yum install font
#yum install -y  bitmap-fonts bitmap-fonts-cjk

#更新并安装基础包
echo " "
echo "开始更新并安装基础包 ..."
#if [[ ${OS} == 'CentOS' ]];then
    #yum erase epel-release -y
    yum install -y epel-release
    yum install -y yum-utils
    yum-config-manager --enable epel
    yum provides -y '*/applydeltarpm'
    yum install -y deltarpm
    yum clean all -y
    yum makecache -y
    #CentOS7
    yum install -y curl wget unzip net-tools nc lsof telnet socat tcping bitmap-fonts bitmap-fonts-cjk iptables iptables-services python-setuptools git python-devel python-pip crontabs zlib-devel bzip2-devel openssl-devel libsodium mbedtls libsodium-devel mbedtls-devel screen
    yum groupinstall -y "Development Tools"
    yum update -y
    #卸载httpd
    systemctl stop httpd
    systemctl disable httpd
    yum remove -y httpd
#else
#   apt-get update -y
#   apt-get install -y deltarpm
#   apt-get install -y build-essential curl wget unzip ntp ntpdate net-tools bitmap-fonts bitmap-fonts-cjk iptables iptables-services python-setuptools git python-devel python-pip
#   apt-get update -y
#   apt-get upgrade -y
#fi
echo " "
echo "#############################################"
echo "更新并安装基础包完成 !"
echo "#############################################"

#安装psutil并更新pip及组件到最新
echo " "
echo "更新pip并安装psutil ..."
pip install --upgrade pip
echo " "
echo "#############################################"
echo "更新pip并安装psutil完成 !"
echo "#############################################"


#更新NTP设置(设置中国时区并同步时间)
echo " "
echo "设置时区并同步时间 ..."
#timedatectl set-timezone Asia/Shanghai
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate time.windows.com
ntpdate us.pool.ntp.org
ntpdate asia.pool.ntp.org
echo "55 7 * * * root ntpdate us.pool.ntp.org >> /root/mxd-repo/log/ntpdate/ntpdate.log" >> /etc/crontab
echo "55 15 * * * root ntpdate us.pool.ntp.org >> /root/mxd-repo/log/ntpdate/ntpdate.log" >> /etc/crontab
echo "55 23 * * * root ntpdate asia.pool.ntp.org >> /root/mxd-repo/log/ntpdate/ntpdate.log" >> /etc/crontab
echo " "
echo "#############################################"
echo "设置时区并同步时间完成 !"
date "+%Y-%m-%d %H:%M:%S"
echo "#############################################"

#禁用SELinux
echo " "
echo "禁用selinux ..."
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
echo " "
echo "#############################################"
echo "禁用selinux完成 !"
echo "#############################################"

#开放SSH端口,变更为证书验证
echo " "
echo "配置SSH ..."
#chmod 700 /root/.ssh/authorized_keys
chmod 600 /root/.ssh
#vi /etc/ssh/sshd_config
echo "
Port 26133" >> /etc/ssh/sshd_config
echo "Port 29282" >> /etc/ssh/sshd_config
#sed -i "/PasswordAuthentication no/c PasswordAuthentication no" /etc/ssh/sshd_config
#sed -i "/RSAAuthentication no/c RSAAuthentication yes" /etc/ssh/sshd_config
#sed -i "/PubkeyAuthentication no/c PubkeyAuthentication yes" /etc/ssh/sshd_config
#sed -i "/PasswordAuthentication yes/c PasswordAuthentication no" /etc/ssh/sshd_config
#sed -i "/RSAAuthentication yes/c RSAAuthentication yes" /etc/ssh/sshd_config
#sed -i "/PubkeyAuthentication yes/c PubkeyAuthentication yes" /etc/ssh/sshd_config
systemctl restart sshd.service
echo " "
echo "#############################################"
echo "配置SSH完成 !"
echo "#############################################"

##设置DNS
#echo " "
#echo "设置DNS ..."
##echo "search vps" > /etc/resolv.conf
#echo "nameserver 1.1.1.1" > /etc/resolv.conf
#echo "nameserver 8.8.8.8" >> /etc/resolv.conf
#echo "nameserver 8.8.4.4" >> /etc/resolv.conf
#echo "nameserver 74.82.42.42" >> /etc/resolv.conf
#echo " "
#echo "#############################################"
#echo "设置DNS完成 !"
#echo "#############################################"

##设置file-max
#echo " "
#echo "设置limits ..."
#echo "
#fs.file-max=${nofile}" >> /etc/sysctl.conf
#sysctl -p
#echo "
#* hard nproc  65536" >> /etc/security/limits.conf
#echo "* soft nproc  65536" >> /etc/security/limits.conf
#echo "* hard nofile ${nofile}" >> /etc/security/limits.conf
#echo "* soft nofile ${nofile}" >> /etc/security/limits.conf
#echo " "
#echo "#############################################"
#echo "设置limits完成 !"
#echo "#############################################"

#关闭firewalld
echo " "
echo "关闭firewalld ..."
systemctl stop firewalld
systemctl disable firewalld
echo " "
echo "#############################################"
echo "关闭firewalld完成 !"
echo "#############################################"

echo " "
echo "配置iptables ..."
#查看iptables现有规则
iptables -L -n
#先允许所有,不然有可能会杯具
iptables -P INPUT ACCEPT
#清空所有默认规则
iptables -F
#清空所有自定义规则
iptables -X
#所有计数器归0
iptables -Z
#允许来自于lo接口的数据包(本地访问)
iptables -A INPUT -i lo -j ACCEPT
#开放SSH端口
iptables -A INPUT -p tcp --dport 26133 -j ACCEPT
iptables -A INPUT -p tcp --dport 29282 -j ACCEPT
#开放80端口(HTTP)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p udp --dport 80 -j ACCEPT
#开放443端口(HTTPS)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p udp --dport 443 -j ACCEPT
#Caddy入口端口(V2Ray备用端口)
iptables -A INPUT -p tcp --dport 383 -j ACCEPT
iptables -A INPUT -p udp --dport 383 -j ACCEPT
#开放Supervisor端口
iptables -A INPUT -p tcp --dport 990 -j ACCEPT
#开放V2Ray端口
#iptables -A INPUT -p tcp --dport 991 -j ACCEPT
#iptables -A INPUT -p udp --dport 991 -j ACCEPT
#ServerStatus
#iptables -A INPUT -p tcp --dport 35601 -j ACCEPT
#iptables -A INPUT -p udp --dport 35601 -j ACCEPT
#允许ping
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
#允许接受本机请求之后的返回数据 RELATED,是为FTP设置的
iptables -A INPUT -m state --state  RELATED,ESTABLISHED -j ACCEPT
#其他入站一律丢弃
iptables -P INPUT DROP
#所有出站一律绿灯
iptables -P OUTPUT ACCEPT
#所有转发一律丢弃
iptables -P FORWARD DROP

#保存上述规则
service iptables save
#激活iptables
#注册iptables服务
systemctl enable iptables.service
#开启服务
systemctl start iptables.service
#重启服务已确保规则生效(如果防火墙处于已开启状态的话)
systemctl restart iptables.service
#查看状态
systemctl status iptables.service
#查看iptables现有规则
iptables -L -n
echo " "
echo "#############################################"
echo "配置iptables完成 !"
echo "#############################################"

#####################################
##删除防火墙规则
#iptables -P INPUT ACCEPT
#iptables -F
#iptables -X
#iptables -Z
#iptables -P INPUT ACCEPT
#iptables -P OUTPUT ACCEPT
#iptables -P FORWARD ACCEPT
#service iptables save
#systemctl restart iptables.service
#####################################

##安装libsodium
#echo " "
#echo "安装libsodium ..."
#curl -sSL https://raw.githubusercontent.com/MxdStudio/scripts/master/01.Common/install_libsodium.sh | sh
#echo " "
#echo "#############################################"
#echo "安装libsodium完成 !"
#echo "#############################################"

#安装python支持
#yum install -y python-setuptools

##安装SSRR
#echo " "
#echo "安装SSRR ..."
#rm -rf /usr/local/shadowsocksr
#git clone -b akkariiin/master https://github.com/shadowsocksrr/shadowsocksr.git /usr/local/shadowsocksr
#echo " "
#echo "#############################################"
#echo "安装SSRR完成 !"
#echo "#############################################"
#
#安装V2Ray
echo " "
echo "安装V2Ray ..."
bash <(curl -L -s https://install.direct/go.sh)
#卸载V2ray官方脚本
systemctl stop v2ray.service
systemctl disable v2ray.service
systemctl mask v2ray.service
if [ ! -f "/lib/systemd/system/v2ray.service" ]; then
    rm -f /lib/systemd/system/v2ray.service
fi
if [ ! -f "/etc/init.d/v2ray" ]; then
    rm -f /etc/init.d/v2ray
fi
echo " "
echo "#############################################"
echo "安装V2Ray完成 !"
echo "#############################################"

##生成Caddy配置文件
#echo " "
#echo "生成Caddy配置文件 ..."
#echo "http://${fulldomain}:80 {
# timeouts none
# redir https://${fulldomain}:443{url}
#}
#https://${fulldomain}:383 {
# timeouts none
# gzip
# log /root/mxd-repo/log/caddy/caddy-access-${subdomain}.log
# tls admin@mxdstudio.net
# proxy / localhost:990 {
#  header_upstream Host {host}
#  header_upstream X-Real-IP {remote}
#  header_upstream X-Forwarded-For {remote}
#  header_upstream X-Forwarded-Proto {scheme}
# }
# proxy /ws localhost:991 {
#  websocket
#  header_upstream -Origin
# }
#}" > /root/mxd-repo/conf/caddy/Caddyfile
#echo " "
#echo "#############################################"
#echo "生成Caddy配置文件完成 !"
#echo "#############################################"

##安装Caddy
#echo " "
#echo "安装Caddy ..."
#curl -sSL https://getcaddy.com | bash -s personal hook.service,http.authz,http.cgi,http.cors,http.filemanager,http.git,http.login,http.minify,http.proxyprotocol,http.realip,http.expires
#echo " "
#echo "#############################################"
#echo "安装Caddy完成 !"
#echo "#############################################"

#安装supervisor
echo " "
echo "安装supervisor ..."
easy_install supervisor
systemctl stop supervisord.service
systemctl disable supervisord.service
if [ ! -f "/etc/init.d/supervisord" ]; then
	rm -f /etc/init.d/supervisord
fi
if [ ! -f "/usr/lib/systemd/system/supervisord.service" ]; then
	rm -f /usr/lib/systemd/system/supervisord.service
fi
wget --no-check-certificate -qO /usr/lib/systemd/system/supervisord.service 'https://raw.githubusercontent.com/MxdStudio/scripts/master/01.Common/CentOS7/supervisord.service'
systemctl enable supervisord.service
echo " "
echo "#############################################"
echo "安装supervisor完成 !"
echo "#############################################"
echo " "
seconds_left=30
echo "脚本全部执行完毕, 将于${seconds_left}秒后自动重启."
echo "倒计时期间, 可以通过 Ctrl+C 取消重启计划."
echo " "
echo "重启倒计时开始 ..."
while [ $seconds_left -gt 0 ];do
  echo -n $seconds_left
  sleep 1
  seconds_left=$(($seconds_left - 1))
  echo -ne "\r     \r" #清除本行文字
done
echo "重启 !"
reboot
