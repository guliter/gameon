#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#sed 's/cc.*/& eeeee/g' file 某行后添加内容
#sed -i '15c webapi_key='$key'' /etc/soga/soga.conf 15行替换内容

# 设置字体颜色函数
function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg(){
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg(){
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white(){
    echo -e "\033[37m\033[01m $1 \033[0m"
}



read -p  "输入节点ID:" node # 节点id

sed -i '7c node_id='$node'' /etc/soga/soga.conf

read -p "输入域名（务必以/结尾）:" url

sed -i '14c webapi_url='$url'' /etc/soga/soga.conf

echo "输入的域名是$url"

read -p "输入前台配置中的 mukey:" key

sed -i '15c webapi_key='$key'' /etc/soga/soga.conf

    echo
    white "--------------检查配置文件-------------"
    red "1.webapi_url【https://xxx.com/】"
    blue "2.webapi_key【sspanel 配置中的 mukey】"
    white "---------以下是配置文件修改内容--------"

sed -n '14,15p' /etc/soga/soga.conf
