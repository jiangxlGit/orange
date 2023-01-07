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
	tar -zxvf $BASE_DIR/$kafkaName.tgz
    echo "-------重命名kafka文件夹-------"
    mv $kafkaName kafka
else
    echo "-------kafka文件夹已存在-------"
fi

echo "-------配置kafka-------"
mkdir -p $BASE_DIR/kafka/data
cd $BASE_DIR/kafka/config/

cat /dev/null > $BASE_DIR/kafka/config/server.properties

echo "zookeeper.connect=$1:2181,$2:2181,$3:2181" >> $BASE_DIR/kafka/config/server.properties
echo "broker.id=$4" >> $BASE_DIR/kafka/config/server.properties
echo "listeners=PLAINTEXT://0.0.0.0:9092" >> $BASE_DIR/kafka/config/server.properties
echo "advertised.listeners=PLAINTEXT://$5:9092" >> $BASE_DIR/kafka/config/server.properties
echo "advertised.host.name=$5" >> $BASE_DIR/kafka/config/server.properties
echo "log.dirs=$BASE_DIR/kafka/data" >> $BASE_DIR/kafka/config/server.properties
echo "num.network.threads=3" >> $BASE_DIR/kafka/config/server.properties
echo "num.io.threads=8" >> $BASE_DIR/kafka/config/server.properties
echo "socket.send.buffer.bytes=102400" >> $BASE_DIR/kafka/config/server.properties
echo "socket.receive.buffer.bytes=102400" >> $BASE_DIR/kafka/config/server.properties
echo "socket.request.max.bytes=104857600" >> $BASE_DIR/kafka/config/server.properties
echo "num.partitions=3" >> $BASE_DIR/kafka/config/server.properties
echo "num.recovery.threads.per.data.dir=1" >> $BASE_DIR/kafka/config/server.properties
echo "offsets.topic.replication.factor=1" >> $BASE_DIR/kafka/config/server.properties
echo "transaction.state.log.replication.factor=1" >> $BASE_DIR/kafka/config/server.properties
echo "transaction.state.log.min.isr=1" >> $BASE_DIR/kafka/config/server.properties
echo "log.retention.hours=72" >> $BASE_DIR/kafka/config/server.properties
echo "log.segment.bytes=1073741824" >> $BASE_DIR/kafka/config/server.properties
echo "log.retention.check.interval.ms=300000" >> $BASE_DIR/kafka/config/server.properties
echo "delete.topic.enable=true" >> $BASE_DIR/kafka/config/server.properties
echo "zookeeper.connection.timeout.ms=6000" >> $BASE_DIR/kafka/config/server.properties
echo "group.initial.rebalance.delay.ms=3000" >> $BASE_DIR/kafka/config/server.properties

echo "-------启动kafka服务...-------"
$BASE_DIR/kafka/bin/kafka-server-start.sh -daemon $BASE_DIR/kafka/config/server.properties
sleep 5s

echo "-------测试kafka服务-------"
$BASE_DIR/kafka/bin//kafka-topics.sh --topic test --bootstrap-server 127.0.0.1:9092 --partitions 3 --replication-factor 2
sleep 1s
$BASE_DIR/kafka/bin//kafka-topics.sh --bootstrap-server 127.0.0.1:9092 --describe

echo '================================================================'
echo '完成安装kafka服务'
echo '================================================================'