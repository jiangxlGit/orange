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
cat <<EOF > $BASE_DIR/zookeeper/conf/zoo.cfg
clientPort=2181
tickTime=2000
initLimit=10
syncLimit=5
server.1=$1:2188:2888
server.2=$2:2188:2888
server.3=$3:2188:2888
dataDir=$BASE_DIR/zookeeper/conf/data
quorumListenOnAllIPs=true
EOF
echo "$4" > $BASE_DIR/zookeeper/conf/data/myid

# generate redis-cluster service file
cat << EOT > $BASE_DIR/zookeeper/zookeeper-cluster.service
[Unit]
Description=Zookeeper service
After=network.target
 
[Service]
Type=forking
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/jdk1.8.0_141/bin/"
User=root
Group=root
ExecStart=/usr/local/zookeeper/zookeeper/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/zookeeper/bin/zkServer.sh stop
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
EOT

# create service
echo "创建redis服务自启动"
chmod 777 /etc/rc.d/rc.local
cat << EOT >> /etc/rc.d/rc.local
$BASE_DIR/zookeeper/bin/zkServer.sh start
EOT
ln -s $BASE_DIR/zookeeper/zookeeper-cluster.service /usr/lib/systemd/system/zookeeper-cluster.service
sudo systemctl daemon-reload && sudo systemctl enable zookeeper-cluster.service && sudo systemctl start zookeeper-cluster.service

echo "-------启动zookeeper服务...-------"
#$BASE_DIR/zookeeper/bin/zkServer.sh start
#sleep 5s
$BASE_DIR/zookeeper/bin/zkServer.sh status

echo ""
echo "完成集群创建!"
echo ""
echo "测试集群命令: /usr/local/zookeeper/zookeeper/bin/zkCli.sh  -server localhost:2181"
echo ""
echo "create /test data1"
echo ""
echo "ls /"

echo '================================================================'
echo '完成安装zookeeper服务'
echo '================================================================'
