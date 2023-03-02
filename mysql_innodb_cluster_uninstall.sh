#!/bin/bash

echo "@@@@@ 开始卸载mysql @@@@@"

# mysql版本
mysqlVer='8.0.30-1.el7.x86_64'
# 卸载
rpm -ev mysql-community-common-$mysqlVer  --nodeps 
rpm -ev mysql-community-libs-$mysqlVer  --nodeps 
rpm -ev mysql-community-client-$mysqlVer  --nodeps 
rpm -ev mysql-community-server-$mysqlVer  --nodeps
rm -rf /var/lib/mysql/* 


echo "@@@@@ mysql卸载完成 @@@@@"