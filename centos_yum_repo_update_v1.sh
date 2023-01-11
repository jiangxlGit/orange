#!/bin/bash

clear;

echo '================================================================'
echo '开始更换centos7的镜像仓库'
echo '================================================================'

echo '首先备份/etc/yum.repos.d/CentOS-Base.repo'
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

echo '下载新的repo文件'
cd /etc/yum.repos.d
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.163.com/.help/CentOS7-Base-163.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo


echo '生成缓存'
yum clean all
yum makecache

echo '================================================================'
echo '完成更换centos7的镜像仓库'
echo '================================================================'
