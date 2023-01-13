#!/bin/bash

clear;

echo '================================================================'
echo '开始安装mysql服务(集群)'
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

if [ ! -f $BASE_DIR/galera-* ] && [ ! -f $BASE_DIR/mysql-wsrep-* ];then
	echo "-------下载Galera和wsrep-------"
	wget -i -c http://releases.galeracluster.com/galera-3/centos/7/x86_64/galera-3-25.3.37-1.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-5.7-5.7.39-25.31.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-client-5.7-5.7.39-25.31.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-common-5.7-5.7.39-25.31.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-devel-5.7-5.7.39-25.31.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-libs-5.7-5.7.39-25.31.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-libs-compat-5.7-5.7.39-25.31.el7.x86_64.rpm
	wget -i -c http://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/mysql-wsrep-server-5.7-5.7.39-25.31.el7.x86_64.rpm
else
    echo "-------Galera和wsrep文件已存在-------"
fi

echo "-------安装依赖包-------"
yum -y install lsof net-tools perl socat openssl openssl-devel boost-devel rsync jemalloc libmysqlclient stunnel
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm



echo "-------发送到从服务器-------"
scp galera-3-25.3.37-1.el7.x86_64.rpm root@$2:$BASE_DIR
scp mysql-wsrep-*.rpm root@$2:$BASE_DIR


rpm -qa | grep mysql-wsrep
if [ $? -ne 0 ]
then
	echo "-------安装Galera和wsrep-------"
    rpm -ivh --nodeps galera-3-25.3.37-1.el7.x86_64.rpm
    sleep 2s
	rpm -ivh --nodeps mysql-wsrep-libs-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
	rpm -ivh --nodeps mysql-wsrep-devel-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
	rpm -ivh --nodeps mysql-wsrep-libs-compat-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
	rpm -ivh --nodeps mysql-wsrep-common-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
	rpm -ivh --nodeps mysql-wsrep-client-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
	rpm -ivh --nodeps mysql-wsrep-server-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
	rpm -ivh --nodeps mysql-wsrep-5.7-5.7.39-25.31.el7.x86_64.rpm
	sleep 2s
else
    echo "-------Galera和wsrep已安装-------"
fi


echo "-------追加配置到/etc/my.cnf-------"
cat >>/etc/my.cnf << EOF
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld.pid

wsrep_node_name=node$1                                  # 该节点的名称
wsrep_node_address="$2"                                 # 该节点的地址
wsrep-provider=/usr/lib64/galera-3/libgalera_smm.so     # wsrep提供者，我的是在这个目录下
wsrep_cluster_name='mysql_cluster'                      # 集群的名字，必须是统一的
wsrep_cluster_address=gcomm://$3                        # 集群中的其他节点地址 43.139.242.81,43.139.96.249
wsrep_sst_method=rsync                                  # 集群使用rsync同步方式
wsrep_sst_auth=rsync:123456                             # 集群同步的用户名密码
EOF


echo "-------启动mysql-------"
if [ $? -eq 1 ]
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
    systemctl start mysqld
	systemctl status mysqld
fi

mysql -uroot -p"Jiang13479@" --connect-expired-password << EOF
	show status like 'wsrep_local_state_comment';
	show status like 'wsrep_cluster_size';
    quit
EOF



echo '================================================================'
echo '完成安装mysql服务(集群)'
echo '================================================================'