#!/bin/bash

echo "@@@@@ mysql开始安装 @@@@@"

mysqlVer='8.0.30-1.el7.x86_64'

echo "-------卸载mariadb-------"
rpm -qa| grep mariadb
if [ $? -ne 0 ]
then
    echo "-------mariadb已卸载-------"
else
    rpm -qa| grep mariadb | xargs rpm -e --nodeps
    if [ $? -eq 0 ]
    then
        echo "-------卸载mariadb成功-------"
    fi
fi

wget "https://downloads.mysql.com/archives/get/p/23/file/mysql-$mysqlVer.rpm-bundle.tar"
tar -xvf mysql-8.0.30-1.el7.x86_64.rpm-bundle.tar

rpm -ivh mysql-community-common-$mysqlVer.rpm
rpm -ivh mysql-community-client-plugins-$mysqlVer.rpm
rpm -ivh mysql-community-libs-$mysqlVer.rpm
rpm -ivh mysql-community-client-$mysqlVer.rpm
rpm -ivh mysql-community-icu-data-files-$mysqlVer.rpm
rpm -ivh mysql-community-server-$mysqlVer.rpm

rpm -qa | grep -i mysql


mysqld --initialize
chown -R mysql:mysql /var/lib/mysql


echo "-------启动mysql服务-------"
systemctl start mysqld
systemctl status mysqld

echo "-------获取mysql初始密码-------"
str=$(grep "password is generated for root@localhost:" /var/log/mysqld.log)
localPWD=${str##*"root@localhost: "}
echo "-------数据库默认密码:$localPWD-------"


echo "-------登录mysql,修改密码,配置可远程登录-------"
mysql -uroot -p"$localPWD" --connect-expired-password << EOF
    ALTER user 'root'@'%' IDENTIFIED WITH mysql_native_password BY "Jiang13479@";
    use mysql;
    UPDATE user set host='%' WHERE user='root';
    flush privileges;
    quit
EOF

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

#服务器节点id，一般为服务器ip方便区分
server-id=131
#开启日志文件
log-bin=mysql-bin
#指定要同步的数据库，多个用逗号隔开(可以不用配置)
#binlog_do_db=gi_test

show variables like '%server_id%';

echo "-------登录mysql,修改密码,配置可远程登录 完成-------"

echo "@@@@@ mysql完成安装 @@@@@"














