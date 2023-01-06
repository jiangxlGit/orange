#!/bin/bash

clear;

echo '================================================================';
echo '完成安装redis集群脚本';
echo '================================================================';

echo "配置redis集群..."
/usr/local/bin/redis-cli --cluster create $1:7000 $1:7001 $2:7000 $2:7001 $3:7000 $3:7001 --cluster-replicas 1 -a Jiang13479@
echo "配置完成!"

# generate redis-cluster service file
cat << EOT > $BASE_DIR/redis-cluster.service
[Unit]
Description=Redis 7.0 Cluster Service
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/redis-cluster/startup.sh

[Install]
WantedBy=default.target
EOT

# create service
echo "创建redis集群服务..."
ln -s $BASE_DIR/$SERVICE /etc/systemd/system/$SERVICE 
sudo systemctl daemon-reload && sudo systemctl enable $SERVICE && sudo systemctl start $SERVICE

# Cluster OK
echo ""
echo "完成集群创建!"
echo ""
echo "测试集群命令: /usr/local/bin/redis-cli -h 127.0.0.1 -p 7000"
echo ""
echo "127.0.0.1:7000>auth Jiang13479@"
echo ""
echo "127.0.0.1:7000>cluster nodes"

echo '================================================================';
echo '完成安装redis集群脚本';
echo '================================================================';
