# 服务器部署脚本

# ------ 基础服务部署脚本 ------
## jdk部署脚本
java_install_v1.sh

# ------ 单机部署脚本 ------
## mysql单机部署脚本
mysql_standalone_install_v1.sh

## nacos单机部署脚本(要先安装mysql)
sh nacos_standalone_install_v1.sh

## redis单机部署脚本
sh redis_standalone_install_v1.sh

## nginx单机部署脚本
sh nginx_standalone_install_v1.sh


# ------ 集群部署脚本 ------
## mysql集群部署脚本(需要先下载my_test.cnf文件)
sh mysql_galera_cluster_install_v1.sh <本节点hostname> <本节点公网ip> <节点2公网ip> 106.14.17.131,43.139.242.81

## nacos集群部署脚本(要先安装mysql)
sh nacos_cluster_install_v1.sh

## redis集群部署脚本
sh redis_cluster_install_v1.sh
sh redis_cluster_deploy_v1.sh 106.14.17.131 43.139.242.81 43.139.96.249
$1:服务1ip，$2:服务2ip，$3:服务3ip

## zookeeper集群部署脚本
sh zookeeper_cluster_install_v1.sh 106.14.17.131 43.139.242.81 43.139.96.249 1
$1:服务1ip，$2:服务2ip，$3:服务3ip，$4:服务编号，如服务1就是1

## kafka集群部署脚本
sh kafka_cluster_install_v1.sh 106.14.17.131 43.139.242.81 43.139.96.249 1 106.14.17.131
$1:服务1ip，$2:服务2ip，$3:服务3ip，$4:brokerId，$5:当前服务器公网ip

