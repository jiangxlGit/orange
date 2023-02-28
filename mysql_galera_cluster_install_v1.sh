#!/bin/bash

clear;

echo '================================================================'
echo '开始安装mysql服务(集群)'
echo '需要开放3306，4444，4567，4568端口'
echo '================================================================'
#***************************************************************************************

BASE_DIR=/usr/local/mysql

echo "-------新建并进入目录/usr/local/mysql-------"
mkdir -p $BASE_DIR
cd $BASE_DIR

echo "-------设置SELinux策略，在SELinux下允许myql连接-------"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

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

echo "-------安装依赖包-------"
yum update
yum -y install lsof net-tools perl socat openssl openssl-devel boost-devel rsync jemalloc libmysqlclient stunnel libaio libev perl perl-DBD-MySQL perl-Digest-MD5
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

echo "-------卸载安装包-------"
rpm -ev --nodeps galera-3-25.3.37-1.el7.x86_64
rpm -ev --nodeps mysql-wsrep-libs-5.7-5.7.39-25.31.el7.x86_64
rpm -ev --nodeps mysql-wsrep-devel-5.7-5.7.39-25.31.el7.x86_64
rpm -ev --nodeps mysql-wsrep-libs-compat-5.7-5.7.39-25.31.el7.x86_64
rpm -ev --nodeps mysql-wsrep-common-5.7-5.7.39-25.31.el7.x86_64
rpm -ev --nodeps mysql-wsrep-client-5.7-5.7.39-25.31.el7.x86_64
rpm -ev --nodeps mysql-wsrep-server-5.7-5.7.39-25.31.el7.x86_64
rpm -ev --nodeps mysql-wsrep-5.7-5.7.39-25.31.el7.x86_64

wget https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.15/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.15-1.el7.x86_64.rpm
rpm -ivh percona-xtrabackup-24-2.4.15-1.el7.x86_64.rpm


temp=`rpm -qa | grep mysql-wsrep-common`
if [[ $temp == 'mysql-wsrep-common-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-common-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps mysql-wsrep-common-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep mysql-wsrep-libs`
if [[ $temp == 'mysql-wsrep-libs-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-libs-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps  mysql-wsrep-libs-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep mysql-wsrep-client`
if [[ $temp == 'mysql-wsrep-client-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-client-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps  mysql-wsrep-client-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep mysql-wsrep-libs-compat`
if [[ $temp == 'mysql-wsrep-libs-compat-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-libs-compat-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps  mysql-wsrep-libs-compat-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep mysql-wsrep-server`
if [[ $temp == 'mysql-wsrep-server-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-server-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps  mysql-wsrep-server-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep mysql-wsrep`
if [[ $temp == 'mysql-wsrep-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps  mysql-wsrep-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep mysql-wsrep-devel`
if [[ $temp == 'mysql-wsrep-devel-5.7-5.7.39-25.31.el7.x86_64' ]]; then
	echo '已安装：mysql-wsrep-devel-5.7-5.7.39-25.31.el7.x86_64'
else
	rpm -ivh --nodeps  mysql-wsrep-devel-5.7-5.7.39-25.31.el7.x86_64.rpm
fi

temp=`rpm -qa | grep galera`
if [[ $temp == 'galera-3-25.3.37-1.el7.x86_64' ]]; then
	echo '已安装：galera-3-25.3.37-1.el7.x86_64'
else
	rpm -ivh --nodeps  galera-3-25.3.37-1.el7.x86_64.rpm
fi


echo "-------追加配置到/etc/my.cnf-------"
cat >/etc/my.cnf << EOF
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

server_id=$4
binlog_format=row
default_storage_engine=InnoDB
innodb_file_per_table=1
innodb_autoinc_lock_mode=2

wsrep_on=ON
wsrep_node_name=$1                                  # 该节点的名称
wsrep_node_address="$2"                                 # 该节点的地址
wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so     # wsrep提供者，我的是在这个目录下
wsrep_cluster_name='mysql_cluster'                      # 集群的名字，必须是统一的
wsrep_cluster_address=gcomm://$3                        # 集群中的其他节点地址 43.139.242.81,43.139.96.249
wsrep_sst_method=rsync                                  # 集群使用rsync同步方式
wsrep_sst_auth=rsync:123456                             # 集群同步的用户名密码
EOF
cat /etc/my.cnf

echo "-------启动mysql-------"
if [ $1 == master ]
then
    echo "-------启动主节点mysql-------"
	bash /usr/bin/mysqld_bootstrap
	sleep 5s
	systemctl status mysqld


	echo "-------获取默认密码-------"
	mysqlPasswordStr=$(grep "password is generated for root@localhost:" /var/log/mysqld.log)
	mysqlPassword=${mysqlPasswordStr##*"root@localhost: "}
	echo "mysql默认密码：$mysqlPassword"


	echo "-------登录mysql,修改密码,配置可远程登录-------"
mysql -uroot -p"$mysqlPassword" --connect-expired-password << EOF
		ALTER user 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY "Jiang13479@";
	    use mysql;
	    UPDATE user set host='%' WHERE user='root';
	    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
	    flush privileges;
	    quit
EOF

else
	
echo "-------启动从节点-------"
systemctl start mysqld
systemctl status mysqld

fi


echo '================================================================'
echo '完成安装mysql服务(集群)'
echo '================================================================'
