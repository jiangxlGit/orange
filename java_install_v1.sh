#!/bin/bash
#此脚本用于安装JDK

echo "@@@@@ JDK开始安装 @@@@@"

#存放目录
storageDir=/data/soft
#安装目录
installDir=/usr/local
#判断目录是否存在，不存在则创建
if [ ! -d "$storageDir" ]; then
	mkdir $storageDir
fi
if [ ! -d "$installDir" ]; then
	mkdir $installDir
fi

#搜索当前环境是否安装有JDK
echo "搜索当前环境是否安装有JDK"

jdkExist=`rpm -qa|grep java`
#通过上述命令返回值判断jdk是否存在
if [ $? -eq 0 ];then
	#如果jdk存在则卸载
	yum -y remove java*
fi


#执行安装程序
echo "-------正在查找相关软件包-------"

#判断软件包是否存在
if [ -f $storageDir/jdk*.tar.gz ];then
	echo "-------安装文件-------"
	echo "-------jdk安装程序正在执行中,请等待-------"
	tar -zxf $storageDir/jdk*.tar.gz -C $installDir
else
    cd $storageDir
	echo "jdk安装包不存在,进行下载"
    echo "-------jdk安装正在下载中,请等待-------"
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz"
    echo "-------安装文件-------"
	echo "-------jdk安装程序正在执行中,请等待-------"
    tar -zxf $storageDir/jdk*.tar.gz -C $installDir
fi

# 配置JDK环境变量
echo "-------jdk安装完成，正在将jdk添加到环境变量中-------"
echo '#jdk' >>/etc/profile
echo "export JAVA_HOME=$installDir/jdk1.8.0_141" >>/etc/profile
echo 'export JRE_HOME=$JAVA_HOME/jre' >>/etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin' >>/etc/profile
echo 'CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >>/etc/profile
echo 'export JAVA_HOME JRE_HOME PATH CLASSPATH' >>/etc/profile 

# 刷新环境变量
echo "-------正在刷新环境变量-------"
source /etc/profile
echo "@@@@@ JDK安装完成 @@@@@"
