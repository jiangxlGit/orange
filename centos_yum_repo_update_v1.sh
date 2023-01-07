#!/bin/bash

clear;

echo '================================================================'
echo '开始更换centos7的镜像仓库'
echo '================================================================'

echo '首先备份/etc/yum.repos.d/CentOS-Base.repo'
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

echo '下载新的repo文件'
cd /etc/yum.repos.d
wget -i -c https://mirrors.163.com/.help/CentOS7-Base-163.repo

echo '生成缓存'
yum clean all
yum makecache

echo '================================================================'
echo '完成更换centos7的镜像仓库'
echo '================================================================'
