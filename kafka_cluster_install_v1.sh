#!/bin/bash

clear;

echo '================================================================'
echo '开始安装kafka服务'
echo '================================================================'
#***************************************************************************************
kafkaVer="3.3.1"
kafkaName="kafka_2.13-$kafkaVer"
BASE_DIR=/usr/local/kafka


echo "-------创建目录/usr/local/kafka-------"
if [ ! -d "$BASE_DIR" ]; then
	mkdir -p $BASE_DIR
fi

echo "-------安装wget-------"
yum -y install wget


echo "-------下载kafka安装包-------"
cd $BASE_DIR
if [ ! -f $BASE_DIR/$kafkaName* ];then
	wget --no-check-certificate -i -c https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/$kafkaVer/$kafkaName.tgz
else
    echo "-------kafka安装包已存在-------"
fi


if [ ! -d "$BASE_DIR/kafka" ]; then
	echo "-------解压kafka安装包-------"
	tar -zxvf $BASE_DIR/$kafkaName.tar.gz
    echo "-------重命名kafka文件夹-------"
    mv $kafkaName kafka
else
    echo "-------kafka文件夹已存在-------"
fi

echo "-------配置kafka-------"
mkdir -p $BASE_DIR/kafka/kafka/data
cd $BASE_DIR/kafka/config/

if [[ $4 -eq "1" ]]; then
	ip=$1
elif [[ $4 -eq "2" ]]; then
	ip=$2
elif [[ $4 -eq "3" ]]; then
	ip=$3


echo "log.dirs=$BASE_DIR/kafka/kafka/data" >> $BASE_DIR/kafka/config/zookeeper.properties
cat << EOF > $BASE_DIR/kafka/config/zookeeper.properties
# 修改Kafka_node的IP地址为各自node本地地址                                         
listeners=PLAINTEXT://$ip:9092   
zookeeper.connect=$1:2181,$2:2181,$3:2181
# Kafka_node2节点修改为2，3修改为3
broker.id=$4                   
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=$BASE_DIR/kafka/kafka/data
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=72
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
delete.topic.enable=true
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=3000
EOF

echo "-------启动kafka服务...-------"
$BASE_DIR/kafka/bin/kafka-server-start.sh -daemon $BASE_DIR/kafka/config/server.properties
sleep 5s

echo '================================================================'
echo '完成安装kafka服务'
echo ''
echo '================================================================'
