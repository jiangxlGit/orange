#!/bin/bash

clear;

echo '================================================================'
echo '开始安装nginx服务'
echo '================================================================'
#***************************************************************************************

if [ $USER != root ];then
echo "当前不是root用户，请切换至root用户再次运行脚本"
exit
fi
ping -c3 -i0.1 -W1 www.baidu.com &> /dev/null
if [ $? != 0 ];then
echo "当前无网络，请保证网络畅通再次运行脚本"
exit
else
echo "当前网络畅通，即将开始运行脚本"
fi
sleep 2

echo "-------关闭selinux-------"
sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
setenforce 0

echo "-------正在安装依赖包，请稍等....-------"
yum -y install  gcc-c++  && yum install -y pcre pcre-devel  &&  yum install -y zlib zlib-devel  && yum install -y openssl openssl-devel 
cd /usr/local/src
echo "-------正在下载压缩包，请稍等....-------"
wget -i -c https://nginx.org/download/nginx-1.20.2.tar.gz
tar xvfz nginx-1.20.2.tar.gz
echo "-------正在配置，请稍等....-------"
sleep 2
cd nginx-1.20.2 && ./configure --prefix=/usr/local/nginx
echo "-------正在安装服务请稍等...-------"
sleep 2
make && make install
echo "-------正在将nginx注册为系统服务-------"
sleep 2
cat>>/lib/systemd/system/nginx.service<< EOF
[Unit]
Description=nginx
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
if [ $? -eq 0 ];then
echo -e "\033[32m ........OK! \033[0m"
fi
read -p "是否部署nginx服务开机自启（yes/no）：" fw 
case $fw in 
yes) 
systemctl start nginx.service && systemctl enable nginx.service 
systemctl status nginx.service 
echo "端口已开启成功" && netstat -ntlp | grep 80 
echo -e "服务及开机自启部署成功，请输入\033[32mifconfig | grep inet | cut -d \" \" -f 10 | head -1\033[0m测试" 
;; 
no) 
systemctl start nginx.service && systemctl disable nginx.service 
systemctl status nginx.service 
echo "端口已开启成功" && netstat -ntlp | grep 80 
echo "服务部署成功，请输入ifconfig | grep inet | cut -d \" \" -f 10 | head -1测试" 
;; 
*) 
echo "请选择是否部署服务开机自启yes/no" 
esac

echo '================================================================'
echo '完成安装nginx服务'
echo '================================================================'











