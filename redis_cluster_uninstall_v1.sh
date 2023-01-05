  #!/bin/bash

clear;

echo '================================================================';
echo '开始卸载redis服务';
echo '================================================================';

BASE_DIR=/usr/local/redis-cluster/

# 杀死redis服务器
ps -ef | grep redis-server | grep cluster | awk '{print $2}' | xargs kill -9 

# 禁用systemd
systemctl disable redis-cluster.service

# 删除redis集群目录
if [ -f "/usr/local/redis-cluster" ]; then
	rm -rf /usr/local/redis-cluster/
fi

echo '================================================================';
echo '完成卸载redis服务';
echo '================================================================';
