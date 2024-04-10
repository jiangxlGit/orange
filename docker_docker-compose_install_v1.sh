#!/bin/bash
#此脚本用于安装docker

echo "@@@@@ docker开始安装 @@@@@"


echo "---- 更新yum ----"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum makecache fast

echo "---- 移除旧docker ----"
sudo yum remove docker
sudo yum remove docker docker-common docker-selinux docker-engine

echo "---- 安装docker（指定版本） ----"
sudo  yum install docker-ce-24.0.7 docker-ce-cli-24.0.7 containerd.io
systemctl enable docker.service
systemctl is-enabled docker.service
sudo systemctl start docker
docker -v

echo "---- 配置docker镜像加速器(163) ----"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "---- 安装docker-compose（指定版本） ----"
mkdir /data/docker-compose && cd /data/docker-compose
sudo curl -L "https://mirror.ghproxy.com/https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version