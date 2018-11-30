#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 7+
#	Description: Install libsodium
#	Version: 1.0.0
#	Author: MxdStudio
#	Blog: https://www.mxdstudio.net/
#=================================================

#获取最新版本号
echo "=============================="
Libsodiumr_ver=$(wget -qO- "https://github.com/jedisct1/libsodium/tags"|grep "/jedisct1/libsodium/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/') && echo " Latest version: ${Libsodiumr_ver}"
echo "=============================="
#获取源代码
echo "=============================="
echo " Get source..."
echo "=============================="
wget --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}/libsodium-${Libsodiumr_ver}.tar.gz"
#解压缩
echo "=============================="
echo " Decompress source pack..."
echo "=============================="
tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
#编译
echo "=============================="
echo " Compile source..."
echo "=============================="
./configure --disable-maintainer-mode && make -j2 && make install
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
#创建链接
echo "=============================="
echo " Create links..."
echo "=============================="
ldconfig
#删除源代码
echo "=============================="
echo " Delete source..."
echo "=============================="
cd .. && rm -rf libsodium-${Libsodiumr_ver}.tar.gz && rm -rf libsodium-${Libsodiumr_ver}
echo "=============================="
echo " Done"
echo "=============================="

