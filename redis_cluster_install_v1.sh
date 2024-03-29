#!/bin/bash

clear;

echo '================================================================';
echo '开始安装redis服务';
echo '================================================================';
#***************************************************************************************
echo "设置redis版本"
redisVer='redis-7.0.6';

#测算内存，用四分之一内存给redis最大内存使用********************************************
echo "设置redis内存"
RamTotal=`free -m | grep 'Swap' | awk '{print $4}'`;
Ramredis=`expr $RamTotal / 4 \* 1000 \* 1000`;
#***************************************************************************************

BASE_DIR=/usr/local/redis-cluster

PORTS=`seq 7000 7001`

START_UP=$BASE_DIR/startup.sh

SERVICE=redis-cluster.service

# 检查redis是否安装
if [ ! -f "/usr/local/bin/redis-server" ]; then
  echo "Redis 还没有准备好，请先安装 redis！"
  echo ""
  echo "===== 安装redis如下 ====="
  wget http://download.redis.io/releases/$redisVer.tar.gz -P /usr/local/src
  cd /usr/local/src/
  tar -zxvf $redisVer.tar.gz
  cd $redisVer
  # 如果不存在则安装 GCC
  yum install -y gcc-c++
  make MALLOC=libc install
  echo ""
fi

# 用户自定义设置
echo -n "输入主机的公共地址（默认 127.0.0.1）："
read cluster_address


# 新建并进入工作目录
mkdir -p $BASE_DIR
cd $BASE_DIR

# 生成配置文件
function generate_instance_conf() {
  echo "配置redis服务 $1"
  
  # 初始化redis.conf
  echo "" > $1/redis.conf
  # 写入配置
  echo "port $1" >> $1/redis.conf
  echo "bind 0.0.0.0" >> $1/redis.conf
  echo "dir $BASE_DIR/$port/data" >> $1/redis.conf
  echo "maxmemory $Ramredis" >> $1/redis.conf
  echo "maxmemory-policy allkeys-lru" >> $1/redis.conf
  echo "cluster-enabled yes" >> $1/redis.conf
  echo "cluster-config-file nodes-$1.conf" >> $1/redis.conf
  echo "requirepass Jiang13479@" >> $1/redis.conf
  echo "masterauth Jiang13479@" >> $1/redis.conf
  echo "dbfilename 7001dump.rdb" >> $1/redis.conf
  echo "logfile $1.log" >> $1/redis.conf
  echo "appendfilename appendonly-$1.aof" >> $1/redis.conf
  if [ -n "$cluster_address" ]; then 
    echo "cluster-announce-ip $cluster_address" >> $1/redis.conf
  else 
    echo "cluster-announce-ip 127.0.0.1" >> $1/redis.conf
  fi
  echo "appendonly yes" >> $1/redis.conf
  echo "databases 16" >> $1/redis.conf
  echo "daemonize yes" >> $1/redis.conf
  echo "protected-mode no" >> $1/redis.conf
  echo "cluster-announce-port $1" >> $1/redis.conf
  echo "cluster-announce-bus-port 1$1" >> $1/redis.conf
  echo "cluster-node-timeout 20000" >> $1/redis.conf
}


# mkdir目录和设置startup.sh
echo "#!/bin/bash" > $START_UP
servers=
for port in $PORTS; do 
  mkdir -p $BASE_DIR/$port/data
  # generate conf files
  generate_instance_conf $port
  # 
  echo "/usr/local/bin/redis-server $BASE_DIR/$port/redis.conf" >> $START_UP
  # servers
  servers="$servers 127.0.0.1:$port "
done



# startup instances
chmod +x $START_UP
echo "启动redis服务..."
$START_UP
sleep 5s
echo "redis服务准备就绪！"

BASE_DIR=/usr/local/redis-cluster
SERVICE=redis-cluster.service

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
echo "创建redis服务自启动"
chmod 777 /etc/rc.d/rc.local
cat << EOT >> /etc/rc.d/rc.local
/usr/local/redis-cluster/startup.sh
EOT
ln -s $BASE_DIR/$SERVICE /usr/lib/systemd/system/$SERVICE 
sudo systemctl daemon-reload && sudo systemctl enable $SERVICE && sudo systemctl start $SERVICE

echo '================================================================';
echo '完成安装redis服务';
echo '================================================================';

