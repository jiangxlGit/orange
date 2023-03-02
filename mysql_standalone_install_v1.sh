#!/bin/bash

echo "@@@@@ mysql开始安装 @@@@@"

# mysql文件版本
mysqlVer="mysql-8.0.27-linux-glibc2.12-x86_64"
# mysql端口
mysqlPort="23307"
#存放目录
storageDir=/data/soft
#安装目录
installDir=/usr/local
#binlog存放目录
binlogDir=/home/data/mysql/binlog
#判断目录是否存在，不存在则创建
if [ ! -d "$storageDir" ]; then
    mkdir $storageDir
fi
if [ ! -d "$installDir" ]; then
    mkdir $installDir
fi
if [ ! -d "$binlogDir" ]; then
    mkdir -p $binlogDir
fi

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


echo "-------安装wget和libaio-------"
yum -y install wget
yum -y install libaio
cd $storageDir
if [ ! -f $storageDir/$mysqlVer* ];then
    echo "-------下载mysql安装包-------"
    wget --no-cookies --no-check-certificate -i -c https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-8.0/$mysqlVer.tar.xz
else
    echo "-------mysql安装包已存在-------"
fi

echo "-------查询是否存在mysql文件夹-------"
if [ ! -d "$installDir/mysql" ]; then

    echo "-------解压mysql安装包-------"
    tar -Jxvf $storageDir/$mysqlVer.tar.xz -C $installDir

    echo "-------重命名mysql文件夹-------"
    cd $installDir
    mv $mysqlVer mysql
else
    echo "-------mysql文件夹已存在-------"
fi

echo "-------添加PATH变量，可在全局使用mysql-------"
echo '#mysql' >>/etc/profile
echo 'export PATH=$PATH:/usr/local/mysql/bin' >>/etc/profile

echo "-------正在刷新环境变量-------"
source /etc/profile

echo "-------创建data存储文件-------"
mysqlDir=$installDir/mysql
cd $mysqlDir
mkdir data

echo "-------创建用户和用户组，并赋予权限-------"
groupadd mysql
useradd -g mysql mysql
chown -R mysql.mysql $mysqlDir

echo "-------初始化mysql信息-------"
cd $mysqlDir
yum -y install numactl
log=$mysqlDir/mysql_init.log
./bin/mysqld --user=mysql --basedir=$mysqlDir --datadir=$mysqlDir/data/ --initialize 2>&1 | tee $log

echo "-------添加mysqld服务到系统-------"
cd $mysqlDir
cp -a ./support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig --add mysql

echo "-------添加my.cnf-------"
echo "配置数据库编码"
echo "[client]" > /etc/my.cnf
echo "default-character-set=utf8mb4" >> /etc/my.cnf
echo "port=$mysqlPort" >> /etc/my.cnf
echo "" >> /etc/my.cnf
echo "[mysqld]" >> /etc/my.cnf
echo "port=$mysqlPort" >> /etc/my.cnf
echo "basedir=$mysqlDir" >> /etc/my.cnf
echo "datadir=$mysqlDir/data" >> /etc/my.cnf
echo "default-storage-engine=INNODB" >> /etc/my.cnf
echo "socket=$mysqlDir/mysql.sock" >> /etc/my.cnf
echo "character-set-server=utf8mb4" >> /etc/my.cnf
echo "collation-server=utf8mb4_general_ci" >> /etc/my.cnf

cat /etc/my.cnf
chmod 664 /etc/my.cnf

echo "-------启动mysql服务-------"
service mysql start
service mysql status

echo "-------获取mysql初始密码-------"
str=$(grep "password is generated for root@localhost:" $mysqlDir/mysql_init.log)
localPWD=${str##*"root@localhost: "}
echo "-------数据库默认密码:$localPWD-------"

echo "-------mysql.sock建立软连接-------"
ln -s /usr/local/mysql/mysql.sock /tmp/mysql.sock

echo "-------登录mysql,修改密码,配置可远程登录-------"
mysql -uroot -p"$localPWD" --connect-expired-password << EOF
    ALTER user 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY "Jiang13479@";
    use mysql;
    UPDATE user set host='%' WHERE user='root';
    flush privileges;
    quit
EOF
echo "-------登录mysql,修改密码,配置可远程登录 完成-------"

echo "@@@@@ mysql完成安装 @@@@@"
