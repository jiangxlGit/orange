


tar -xvf mysql-8.0.30-1.el7.x86_64.rpm-bundle.tar

mysqlVer='8.0.30-1.el7.x86_64'
rpm -ivh mysql-community-common-$mysqlVer.rpm  --nodeps --force
rpm -ivh mysql-community-libs-$mysqlVer.rpm  --nodeps --force
rpm -ivh mysql-community-client-$mysqlVer.rpm  --nodeps --force
rpm -ivh mysql-community-server-$mysqlVer.rpm  --nodeps --force
rpm -qa | grep -i mysql

mysqld --initialize
chown mysql:mysql /var/lib/mysql -R
systemctl start mysqld.service
systemctl enable mysqld.service


cat /var/log/mysqld.log | grep password

mysql -uroot -p


set global validate_password_policy=0;
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456' PASSWORD EXPIRE NEVER;
set global validate_password_length=1;
flush privileges;
create user 'root'@'%' identified with mysql_native_password by 'Jiang13479@';
grant all privileges on *.* to 'root'@'%' with grant option;
flush privileges;
exit;

vi /etc/my.cnf

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

server_id=131
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
loose-group_replication_local_address= "master:33061"
# 当前主机成员需要加入组时，Server先访问这些种子成员中的一个，然后它请求重新配置以允许它加入组
# 需要注意的是，此参数不需要列出所有组成员，只需列出当前节点加入组需要访问的节点即可。
loose-group_replication_group_seeds= "master:33061,node1:33062,node2:33063"
loose_group_replication_ip_whitelist='106.14.17.131,43.139.242.81,43.139.96.249'
# 是否自动引导组。此选项只能在一个server实例上使用，通常是首次引导组时(或在整组成员关闭的情况下)，如果多次引导，可能出现脑裂。
loose-group_replication_bootstrap_group=OFF
cat /etc/my.cnf

systemctl restart mysqld.service


mysql -uroot -p123456
SET SQL_LOG_BIN=0;
CREATE USER mgruser@'%' IDENTIFIED BY '123456';
GRANT REPLICATION SLAVE ON *.* TO mgruser@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='mgruser', MASTER_PASSWORD='123456' FOR CHANNEL 'group_replication_recovery';
install PLUGIN group_replication SONAME 'group_replication.so';
show plugins;

# 主节点
set global group_replication_single_primary_mode=OFF;
set global group_replication_enforce_update_everywhere_checks=ON;
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
SELECT * FROM performance_schema.replication_group_members;

# 从节点
START GROUP_REPLICATION;
SELECT * FROM performance_schema.replication_group_members;




# 卸载
mysqlVer='8.0.30-1.el7.x86_64'
rpm -ev mysql-community-common-$mysqlVer  --nodeps 
rpm -ev mysql-community-libs-$mysqlVer  --nodeps 
rpm -ev mysql-community-client-$mysqlVer  --nodeps 
rpm -ev mysql-community-server-$mysqlVer  --nodeps
rm -rf /var/lib/mysql/* 


