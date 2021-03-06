#!/bin/bash SSPanel部署
##检查操作系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}

##检查是否root用户
[ $(id -u) != "0" ] && { echo -e " “\033[31m Error: 必须使用root用户执行此脚本！\033[0m”"; exit 1; }
##定义常用属性
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

clear
#宝塔面板ZFaka快速部署工具
echo -e "感谢使用 “\033[32m GameOnSSPanel 快速部署工具 \033[0m”"
echo "----------------------------------------------------------------------------"
echo -e "请注意这些要求:“添加网址PHP版本必须选择为“\033[31m PHP7.3 \033[0m”,添加完成后地址不要改动,在下方输入网站目录！"
echo "----------------------------------------------------------------------------"
stty erase '^H' && read -p "请输入宝塔面板添加的网站目录,宝塔默认地址应该是域名（不带http/https）：" website
#stty erase '^H' && read -p "请输入宝塔面板添加的MySQL用户名：" mysqlusername
stty erase '^H' && read -p "请输入宝塔面板添加的MySQL数据库名：" mysqldatabase
stty erase '^H' && read -p "请输入宝塔面板添加的MySQL密码：" mysqlpassword
sleep 1
echo -e "${Info} 请确认您输入的网站域名：$website"
#echo -e "${Info} 请确认您输入的MySQL用户名：$mysqlusername"
echo -e "${Info} 请确认您输入的MySQL用户名：$mysqldatabase"
echo -e "${Info} 请确认您输入的MySQL密码：$mysqlpassword"
stty erase '^H' && read -p " 请输入数字(1：继续；2：退出) [1/2]:" status
case "$status" in
	1)
	echo -e "${Info} 您选择了继续，开始安装程序！"
	;;
	2)
	echo -e "${Tip} 您选择了退出，请重新执行安装程序！" && exit 1
	;;
	*)
	echo -e  "${Error} 请输入正确值 [1/2]，请重新执行安装程序" && exit 1
	;;
esac
echo -e "${Info} 请等待系统自动操作......"

#chmod -R 777 /www/wwwroot
#chattr -i /home/wwwroot/$website/.user.ini
rm -rf /www/wwwroot/$website
rm -rf /root/GameOn
mkdir /www/wwwroot/$website

#处理源码
yum install -y  unzip
yum install -y git
cd /root/ && wget https://github.com/guliter/gameon/releases/download/1.0/GameOn.tar.gz &&  chmod +x GameOn.tar.gz && tar -zxvf  GameOn.tar.gz && cd /root/GameOn && mv * .[^.]* /www/wwwroot/$website/ && cd /www/wwwroot/$website 



##处理nginx伪静态和运行目录
echo -e "${Info} 正在处理nginx内容"
echo 'location / {if (!-e $request_filename) {rewrite ^/(.*)$ /index.php?$1 last;}}'> /www/server/panel/vhost/rewrite/$website.conf
sed -i "s:\/www\/wwwroot\/${website}:\/www\/wwwroot\/${website}\/public:g" /www/server/panel/vhost/nginx/$website.conf
sed -i '6c root 	/www/wwwroot/'${website}'/public/;' /www/server/panel/vhost/nginx/$website.conf


echo -e "${Info} 处理nginx内容已完成"
sleep 1

##处理php 关闭 PATH_INFO:
#sed -i "s:include pathinfo.conf:#include pathinfo.conf:g" /www/server/nginx/conf/enable-php-71.conf

#处理PHP禁用函数
sed -i '479c display_errors = Off;' /www/server/php/73/etc/php.ini
sed -i '315c disable_functions = passthru,exec,chroot,chgrp,chown,popen,pcntl_exec,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,imap_open,apache_setenv;' /www/server/php/73/etc/php.ini



cd /root/




##初始化站点信息
echo -e "${Info} 正在配置站点基本信息"
cd /www/wwwroot/$website
#cp conf/application.ini.new conf/application.ini
sed -i "s/GameOn/$mysqldatabase/g" /www/wwwroot/$website/config/.config.php
sed -i "s/1314521/$mysqlpassword/g" /www/wwwroot/$website/config/.config.php
#sed -i '479c display_errors = Off;' /www/server/php/73/etc/php.ini
echo -e "${Info} 配置站点基本信息已完成"
sleep 1


#导入数据库
#echo -e "${Info} 正在导入数据库"
#cd /www/wwwroot/$website/install
#mysql -u$mysqldatabas -p$mysqlpassword $mysqldatabase < faka.sql >/dev/null 2>&1
#echo -e "${Info} 导入数据库已完成"
#sleep 4

echo -e "${Info} 请等确认已在宝塔内导入正确信息的数据库"
#创建管理员
cd /www/wwwroot/$website
php xcat createAdmin
php xcat syncusers
php xcat initQQWry


cd /root/

##加入定时任务
#echo -e "${Info} 正在添加定时任务"
#echo "*/2 * * * * php -q /www/wwwroot/$website/public/cli.php request_uri=\"/crontab/sendemail/index\"" >> /var/spool/cron/root
#chkconfig –level 35 crond on
#/sbin/service crond restart
#echo -e "${Info} 添加定时任务已完成"
#sleep 1

##重启php和nginx
echo -e "${Info} 正在重启PHP"
/etc/init.d/php-fpm-73 restart
echo -e "${Info} 重启PHP已完成"
sleep 1
echo -e "${Info} 正在重启NGINX"
/etc/init.d/nginx restart
echo -e "${Info} 重启NGINX已完成"
sleep 3

#success
echo -e "${Tip} 安装即将完成，倒数五个数！"
sleep 1
clear
echo "-----------------------------"
echo "#############################"
echo "########           ##########"
echo "########   ##################"
echo "########   ##################"
echo "########           ##########"
echo "###############    ##########"
echo "###############    ##########"
echo "########           ##########"
echo "#############################"
sleep 1
clear
echo "-----------------------------"
echo "#############################"
echo "#######   ####   ############"
echo "#######   ####   ############"
echo "#######   ####   ############"
echo "#######               #######"
echo "##############   ############"
echo "##############   ############"
echo "##############   ############"
echo "#############################"
sleep 1
clear
echo "-----------------------------"
echo "#############################"
echo "########            #########"
echo "#################   #########"
echo "#################   #########"
echo "########            #########"
echo "#################   #########"
echo "#################   #########"
echo "########            #########"
echo "#############################"
sleep 1
clear
echo "-----------------------------"
echo "#############################"
echo "########           ##########"
echo "################   ##########"
echo "################   ##########"
echo "########           ##########"
echo "########   ##################"
echo "########   ##################"
echo "########           ##########"
echo "#############################"
sleep 1
clear
echo "-----------------------------"
echo "#############################"
echo "############   ##############"
echo "############   ##############"
echo "############   ##############"
echo "############   ##############"
echo "############   ##############"
echo "############   ##############"
echo "############   ##############"
echo "#############################"
echo "-----------------------------"
sleep 1
clear
echo "--------------------------------------------------------------------------------"
echo -e "${Info} 部署完成，请打开http://$website即可浏览"
echo -e "${Info} 如果打不开站点，请到宝塔面板中软件管理重启nginx和php7.1"
echo -e "${Info} 自定义配置，请登录管理面板进行修改"
echo "--------------------------------------------------------------------------------"



