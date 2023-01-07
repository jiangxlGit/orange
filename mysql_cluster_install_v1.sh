#!/bin/bash

clear;

echo '================================================================'
echo '开始安装mysql集群服务'
echo '================================================================'
#***************************************************************************************


echo "-------安装galera cluster-------"
cat > /etc/yum.repos.d/galera.repo <<-END
[galera]
name = Galera
baseurl = http://releases.galeracluster.com/galera-4/centos/7/x86_64/
gpgkey = http://releases.galeracluster.com/GPG-KEY-galeracluster.com
gpgcheck = 1
[mysql-wsrep]
name = MySQL-wsrep
baseurl = http://releases.galeracluster.com/mysql-wsrep-8.0/centos/7/x86_64/
gpgkey = http://releases.galeracluster.com/GPG-KEY-galeracluster.com
gpgcheck = 1
END

yum makecache
yum -y install gcc gcc-c++ openssl openssl-devel lsof socat perl boost-devel rsync jemalloc libaio libaio-devel net-tools
yum install -y galera-4 mysql-wsrep-8.0


echo "-------设置hosts及主机名-------"
echo "$5 mysql_node$4" >> /etc/hosts
hostnamectl set-hostname "mysql_node$4"


echo "-------/etc/my.cnf配置-------"
cat > /etc/my.cnf <<-END
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[client]
default-character-set=utf8
socket=/var/lib/mysql/mysql.sock

[mysql]
default-character-set=utf8
socket=/var/lib/mysql/mysql.sock

[mysqldump]
socket=/var/lib/mysql/mysql.sock
max_allowed_packet = 512M

[mysqld_safe]
# 内存分配算法调优（默认malloc）
malloc-lib=/usr/lib64/libjemalloc.so.1

[mysqladmin]
socket=/var/lib/mysql/mysql.sock

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove the leading "# " to disable binary logging
# Binary logging captures changes between backups and is enabled by
# default. It's default setting is log_bin=binlog
# disable_log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
#
# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

log_timestamps=SYSTEM
lower_case_table_names=1
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_flush_log_at_trx_commit=0
innodb_buffer_pool_size=128M
binlog_format=ROW
wsrep_on=ON
wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so
wsrep_provider_options="gcache.size=128M; gcache.page_size=128M"
wsrep_slave_threads=4
wsrep_sst_method=rsync
wsrep_sst_auth=rsync:rsync123
END

echo "server_id=$4" >> /etc/my.cnf
echo "wsrep_node_name=\"mysql_node$4\"" >> /etc/my.cnf
echo "wsrep_cluster_name=\"wsrep_cluster\"" >> /etc/my.cnf
echo "wsrep_node_address=\"$5\"" >> /etc/my.cnf
echo "wsrep_cluster_address=\"gcomm://$1,$2,$3\"" >> /etc/my.cnf


echo '初始化节点'
/usr/bin/mysqld_bootstrap
systemctl status mysqld
mysql_pass=`grep 'password is generated' /var/log/mysqld.log |awk '{print $NF}' |awk 'END{print}'` && echo $mysql_pass
mysqladmin -u root -p${mysql_pass} password 'Jiang13479@'


echo '================================================================'
echo '完成安装mysql集群服务'
echo '================================================================'