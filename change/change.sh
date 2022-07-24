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


cd /root
yum install unzip
wget -N --no-check-certificate https://raw.githubusercontent.com/guliter/gameon/main/change/change.zip
unzip change.zip
if [ ! -f "/home/CloudFlare_DDNS" ];then
mkdir /home/CloudFlare_DDNS
else
get_char()
{
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}
greenbg "已经安装过了！重新配置！"
echo "按任意键继续...."
echo " CTRL+C 退出安装...."
char=`get_char`
fi

cp -f /root/config.conf /home/CloudFlare_DDNS
cp -f /root/CloudFlare_DDNS_Setter.sh /home/CloudFlare_DDNS
echo
stty erase '^H' && read -p "请输入邮箱：" em
echo
stty erase '^H' && read -p "Global API Key：" key
echo
stty erase '^H' && read -p "zone_id：" id
echo
cd /home/CloudFlare_DDNS 

> config.conf
cat >> /home/CloudFlare_DDNS/config.conf<<EOF
email=$em
zone_id=$id
api_key=$key

record_id=
domain=
ttl=
EOF

#chmod -R 777 ./CloudFlare_DDNS_Setter.sh
chmod u+x CloudFlare_DDNS_Setter.sh
bash CloudFlare_DDNS_Setter.sh
echo
stty erase '^H' && read -p "record_id：" reid
echo
stty erase '^H' && read -p "解析好的域名：" domain
echo
stty erase '^H' && read -p "解析域名的时间（S）：" ttl
echo

sed -i '5c record_id='${reid}'' /home/CloudFlare_DDNS/config.conf
sed -i '6c domain='${domain}'' /home/CloudFlare_DDNS/config.conf
sed -i '7c ttl='${ttl}'' /home/CloudFlare_DDNS/config.conf

bash CloudFlare_DDNS_Setter.sh --ddns

green "复制：crontab -e 配置定时任务"
green "复制：*/2 * * * * bash CloudFlare_DDNS_Setter.sh --ddns"
