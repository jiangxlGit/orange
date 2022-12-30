#!/bin/bash
clear;
echo '================================================================';
echo '安装redis脚本';
echo '================================================================';
#***************************************************************************************
echo "设置redis版本"
redis='redis-7.0.6';

#测算内存，用三分之一内存给redis最大内存使用********************************************
echo "设置redis内存"
RamTotal=`free -m | grep 'Mem' | awk '{print $2}'`;
Ramredis=`expr $RamTotal / 3 \* 1000 \* 1000`;
#***************************************************************************************
echo "下载redis"
mkdir -p /opt/soft/redis/rediserver;
cd /opt/soft/redis;
wget http://download.redis.io/releases/$redis.tar.gz;

echo "解压redis"
tar zxf $redis.tar.gz;
mv $redis /usr/local/rediserver;
cd /usr/local/rediserver/deps;
make hiredis lua jemalloc linenoise;
cd /usr/local/rediserver;
make&&make install;
useradd -s /sbin/nologin redis;

echo "配置redis"
cd /opt/soft/redis;
mkdir -p log dbdata run;
cp /usr/local/rediserver/redis.conf /opt/soft/redis/redis.conf;
chown -R redis:redis /opt/soft/redis;
sed -i "s/protected-mode/#protected-mode/g" /opt/soft/redis/redis.conf;
sed -i '1i\protected-mode no' /opt/soft/redis/redis.conf;
sed -i "s/pidfile/#pidfile/g" /opt/soft/redis/redis.conf;
sed -i '1i\pidfile "/opt/soft/redis/run/redis_6379.pid"' /opt/soft/redis/redis.conf;
sed -i "s:dir ./:#dir ./:g" /opt/soft/redis/redis.conf;
sed -i '1i\dir "/opt/soft/redis/dbdata"' /opt/soft/redis/redis.conf;
sed -i "s/logfile/#logfile/g" /opt/soft/redis/redis.conf;
sed -i '1i\logfile "/opt/soft/redis/log/redis.log"' /opt/soft/redis/redis.conf;
sed -i "s/# maxmemory <bytes>/maxmemory $Ramredis/g" /opt/soft/redis/redis.conf;
sed -i '1i\maxmemory-policy volatile-lru' /opt/soft/redis/redis.conf;

touch /lib/systemd/system/redis.service;
	
cat >>/lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis data structure server
Requires=network-online.target
After=network.target

[Service]
ExecStart=/usr/local/rediserver/src/redis-server /opt/soft/redis/redis.conf
Restart=always
RestartSec=5
Type=simple
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=default.target
EOF

echo "启动redis"
ln -s /lib/systemd/system/redis.service /etc/systemd/system/multi-user.target.wants/redis;
systemctl daemon-reload;
systemctl enable redis;
systemctl start redis;
echo "@@@@ 安装redis完成 @@@@"
