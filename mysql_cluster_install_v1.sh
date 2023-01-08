#!/bin/bash

clear;

echo '================================================================'
echo '开始安装mysql服务(集群)'
echo '================================================================'
#***************************************************************************************

BASE_DIR=/usr/local/mysql

echo "-------设置SELinux策略，在SELinux下允许myql连接-------"
sudo setsebool -P mysql_connect_any 1


echo "-------linux系统调优-------"
cat>>/etc/sysctl.conf <<EOF
vm.swappiness = 0
fs.aio-max-nr = 1048576
fs.file-max = 681574400
kernel.shmmax = 137438953472
kernel.shmmni = 4096
kernel.sem = 250 32000 100 200
net.ipv4.ip_local_port_range = 9000 65000
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
EOF

cat>>/etc/security/limits.conf <<EOF
mysql soft nproc 65536
mysql hard nproc 65536
mysql soft nofile 65536
mysql hard nofile 65536
EOF

cat>>/etc/profile<<EOF
if [ $USER = "mysql" ]; then
    ulimit -u 16384 -n 65536
fi
EOF

echo "-------新建并进入目录/usr/local/mysql-------"
mkdir -p $BASE_DIR
cd $BASE_DIR


echo "-------下载并解压mysql rpm包-------"
wget -i -c https://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-8.0/mysql-8.0.27-1.el7.x86_64.rpm-bundle.tar
tar -xvf mysql-8.0.27-1.el7.x86_64.rpm-bundle.tar



echo "-------安装mysql server-------"
sudo rpm -ivh mysql-community-common-8.0.27-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-client-plugins-8.0.27-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-libs-8.0.27-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-client-8.0.27-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-server-8.0.27-1.el7.x86_64.rpm

echo "-------删除/var/lib/mysql目录下所有文件-------"
sudo rm -rf /var/lib/mysql/*

echo "-------mysqld初始化-------"
sudo mysqld --initialize
sleep 5s

echo "-------/var/lib/mysql目录改成mysql用户权限-------"
sudo chown mysql:mysql /var/lib/mysql -R

echo "-------启动mysql服务-------"
sudo systemctl start mysqld

echo "-------设置为自动启动-------"
sudo systemctl enable mysqld

echo "-------安装mysql server-------"
mysqlPasswordStr=$(grep "password is generated for root@localhost:" /var/log/mysqld.log)
mysqlPassword=${mysqlPasswordStr##*"root@localhost: "}
echo "mysql默认密码：$mysqlPassword"

echo "-------登录mysql,修改密码,配置可远程登录-------"
mysql -uroot -p"$mysqlPassword" << EOF
    ALTER user 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY "Jiang13479@";
    use mysql;
    UPDATE user set host='%' WHERE user='root';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
    flush privileges;
    quit
EOF

echo '================================================================'
echo '完成安装mysql服务(集群)'
echo '================================================================'