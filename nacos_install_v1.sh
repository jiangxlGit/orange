#!/bin/bash
clear;

echo "@@@@@ nacos开始安装 @@@@@"

# mysql文件版本
verNo="2.2.0"
nacosVer="nacos-server-$verNo"
# mysql密码
mysqlPWD="Jiang13479@"
# mysql端口
mysqlPort="23307"
# 存放目录
storageDir=/data/soft
# 安装目录
installDir=/usr/local

# 判断目录是否存在，不存在则创建
if [ ! -d "$storageDir" ]; then
	mkdir $storageDir
fi
if [ ! -d "$installDir" ]; then
	mkdir $installDir
fi

# 下载nacos安装包
yum -y install wget
cd $storageDir
if [ ! -f $storageDir/$nacosVer* ];then
	echo "-------下载nacos安装包-------"
	wget -i -c "https://ghps.cc/https://github.com/alibaba/nacos/releases/download/$verNo/$nacosVer.tar.gz"
# wget -i -c    https://github.com/alibaba/nacos/releases/download/$verNo/$nacosVer.tar.gz
else
    echo "-------nacos安装包已存在-------"
fi

# 判断nacos目录是否存在，并解压安装包
echo "-------查询是否存在nacos文件夹-------"
if [ ! -d "$installDir/nacos" ]; then
    echo "-------解压nacos安装包-------"
    tar -zxvf $storageDir/$nacosVer.tar.gz -C $installDir
else
    echo "-------nacos文件夹已存在-------"
fi

echo "-------登录mysql并执行mysql-schema.sql-------"
cd $installDir/nacos/conf
mysql -uroot -p"$mysqlPWD" << EOF
    create database nacos_config;
    use nacos_config;
    source mysql-schema.sql;
    quit
EOF

echo "-------修改application.properties-------"
echo "##数据源使用mysql" > $installDir/nacos/conf/application.properties
echo "spring.datasource.platform=mysql" >> $installDir/nacos/conf/application.properties
echo "### Count of DB:" >> $installDir/nacos/conf/application.properties
echo "db.num=1" >> $installDir/nacos/conf/application.properties
echo "### Connect URL of DB:" >> $installDir/nacos/conf/application.properties
echo "db.url.0=jdbc:mysql://127.0.0.1:$mysqlPort/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC" >> $installDir/nacos/conf/application.properties
echo "db.user.0=root" >> $installDir/nacos/conf/application.properties
echo "db.password.0=$mysqlPWD" >> $installDir/nacos/conf/application.properties

echo "-------启动nacos-------"
cd $installDir/nacos/bin
sh  startup.sh -m standalone &
echo "@@@@@ nacos安装完成 @@@@@"
