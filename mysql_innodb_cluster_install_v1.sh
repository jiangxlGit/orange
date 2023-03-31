#!/bin/bash

# mysql版本
mysqlVer='8.0.28-1.el7.x86_64'
# 存放目录
storageDir=/data/soft
# 安装目录
installDir=/usr/local

## 判断mysql是否安装
check_results=`rpm -qa | grep "mysql"`
echo "command(rpm -qa) results are: $check_results"
if [[ $check_results =~ "mysql" ]] 
then 
    echo "mysql已安装！"
else 
	echo "@@@@@ mysql开始安装 @@@@@"
	#判断目录是否存在，不存在则创建
	if [ ! -d "$storageDir" ]; then
	    mkdir -p $storageDir
	fi
	if [ ! -d "$installDir" ]; then
	    mkdir -p $installDir
	fi
	cd $storageDir
	if [ ! -f $storageDir/mysql-$mysqlVer* ];then
	    echo "-------安装包不存在，请下载mysql安装包-------"
	    echo "-------下载mysql安装包地址：https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-$mysqlVer.rpm-bundle.tar-------"
	else
	    echo "-------mysql安装包已存在-------"
	fi

	cd $installDir
	echo "-------查询是否存在mysql文件夹-------"
	if [ ! -d "$installDir/mysql" ]; then

		mkdir -p $installDir/mysql
	    echo "-------解压mysql安装包-------"
	    tar -xvf $storageDir/mysql-$mysqlVer.rpm-bundle.tar -C $installDir/mysql
	else
	    echo "-------mysql文件夹已存在-------"
	fi

	cd $installDir/mysql
	rpm -ivh mysql-community-common-$mysqlVer.rpm  --nodeps --force
	rpm -ivh mysql-community-libs-$mysqlVer.rpm  --nodeps --force
	rpm -ivh mysql-community-client-$mysqlVer.rpm  --nodeps --force
	rpm -ivh mysql-community-server-$mysqlVer.rpm  --nodeps --force
	rpm -qa | grep -i mysql

	mysqld --initialize
	chown mysql:mysql /var/lib/mysql -R
	systemctl start mysqld.service
	systemctl enable mysqld.service


	echo "-------获取mysql初始密码-------"
	str=$(grep "password is generated for root@localhost:" /var/log/mysqld.log)
	localPWD=${str##*"root@localhost: "}
	echo "-------数据库默认密码:$localPWD-------"

	echo "-------登录mysql,修改密码,配置可远程登录-------"
mysql -uroot -p"$localPWD" --connect-expired-password << EOF
	ALTER USER 'root'@'localhost' IDENTIFIED BY '123456' PASSWORD EXPIRE NEVER;
	flush privileges;
	create user 'root'@'%' identified with mysql_native_password by 'Jiang13479@';
	grant all privileges on *.* to 'root'@'%' with grant option;
	flush privileges;
    quit
EOF
	echo "-------登录mysql,修改密码,配置可远程登录 完成-------"


	echo "-------追加配置到/etc/my.cnf-------"
cat > /etc/my.cnf << EOF
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

server_id=$RANDOM
gtid_mode=ON
enforce_gtid_consistency=ON
binlog_checksum=NONE

log_bin=binlog
log_slave_updates=ON
binlog_format=ROW
master_info_repository=TABLE
relay_log_info_repository=TABLE

# 此参数是在server收集写集合的同时以便将其记录到二进制日志。写集合基于每行的主键，并且是行更改后的唯一标识此标识将用于检测冲突。
transaction_write_set_extraction=XXHASH64
# 组的名字可以随便起,但不能用主机的GTID! 所有节点的这个组名必须保持一致！
loose-group_replication_group_name="b6a9971f-b7d8-11ed-8fe5-52540078dac4"
# 启动mysql时不自动启动组复制
loose-group_replication_start_on_boot=OFF
loose-group_replication_recovery_get_public_key=ON
# 本机IP地址或者映射，33061用于接收来自其他组成员的传入连接
loose-group_replication_local_address= "$1:33061"
# 当前主机成员需要加入组时，Server先访问这些种子成员中的一个，然后它请求重新配置以允许它加入组
# 需要注意的是，此参数不需要列出所有组成员，只需列出当前节点加入组需要访问的节点即可。
loose-group_replication_group_seeds= "$1:33061,$2:33061,$3:33061"
loose_group_replication_ip_whitelist='$1,$2,$3'
# 是否自动引导组。此选项只能在一个server实例上使用，通常是首次引导组时(或在整组成员关闭的情况下)，如果多次引导，可能出现脑裂。
loose-group_replication_bootstrap_group=OFF
EOF

	cat /etc/my.cnf

	echo "-------重启mysql-------"
	systemctl restart mysqld.service

	echo "-------创建组复制的账号-------"
mysql -uroot -p123456 << EOF
	SET SQL_LOG_BIN=0;
	CREATE USER mgruser@'%' IDENTIFIED BY '123456';
	GRANT REPLICATION SLAVE ON *.* TO mgruser@'%';
	FLUSH PRIVILEGES;
	SET SQL_LOG_BIN=1;
	CHANGE MASTER TO MASTER_USER='mgruser', MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';
	install PLUGIN group_replication SONAME 'group_replication.so';
	show plugins;
	set global group_replication_single_primary_mode=OFF;
	set global group_replication_enforce_update_everywhere_checks=ON;
	FLUSH PRIVILEGES;
	START GROUP_REPLICATION;
	SELECT * FROM performance_schema.replication_group_members;
	quit
EOF

	echo "@@@@@ mysql完成安装 @@@@@"
fi


