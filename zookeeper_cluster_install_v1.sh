#!/bin/bash

clear;

echo '================================================================'
echo '开始安装zookeeper服务'
echo '================================================================'
#***************************************************************************************
zooVer="zookeeper-3.8.0"
zooName="apache-$zooVer-bin"
BASE_DIR=/usr/local/zookeeper


echo "-------创建目录/usr/local/zookeeper-------"
if [ ! -d "$BASE_DIR" ]; then
	mkdir $BASE_DIR
fi

echo "-------安装wget-------"
yum -y install wget


echo "-------下载zookeeper安装包-------"
cd $BASE_DIR
if [ ! -f $BASE_DIR/$zooName* ];then
	wget --no-check-certificate -i -c https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/$zooVer/$zooName.tar.gz
else
    echo "-------zookeeper安装包已存在-------"
fi


if [ ! -d "$BASE_DIR/zookeeper" ]; then
	echo "-------解压zookeeper安装包-------"
	tar -zxvf $BASE_DIR/$zooName.tar.gz
    echo "-------重命名zookeeper文件夹-------"
    mv $zooName zookeeper
else
    echo "-------zookeeper文件夹已存在-------"
fi

echo "-------配置zookeeper-------"
cd $BASE_DIR/zookeeper/conf/
cp zoo_sample.cfg zoo.cfg
mkdir $BASE_DIR/zookeeper/conf/data
echo "server.1=$1:2188:2888" >> $BASE_DIR/zookeeper/conf/zoo.cfg
echo "server.2=$2:2188:2888" >> $BASE_DIR/zookeeper/conf/zoo.cfg
echo "server.3=$3:2188:2888" >> $BASE_DIR/zookeeper/conf/zoo.cfg
echo "dataDir=$BASE_DIR/zookeeper/conf/data" >> $BASE_DIR/zookeeper/conf/zoo.cfg
echo "quorumListenOnAllIPs=true" >> $BASE_DIR/zookeeper/conf/zoo.cfg
echo "$4" > $BASE_DIR/zookeeper/conf/data/myid

echo "-------启动zookeeper服务...-------"
$BASE_DIR/zookeeper/bin/zkServer.sh start
sleep 5s
$BASE_DIR/zookeeper/bin/zkServer.sh status

echo '================================================================'
echo '完成安装zookeeper服务'
echo '================================================================'
