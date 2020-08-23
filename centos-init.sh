#!/bin/bash
# Filename:    centos7-init.sh
# Author:     magedu@gmail.com
#判断是否为root用户
if [ `whoami` != "root" ];then
echo " only root can run it"
exit 1
fi
#执行前提示
echo -e "\033[31m 这是centos7系统初始化脚本，将更新系统内核至最新版本，请慎重运行！\033[0m" 
read -s -n1 -p "Press any key to continue or ctrl+C to cancel"
echo "Your inputs: $REPLY"
#1.定义配置yum源的函数
yum_config(){
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
yum clean all && yum makecache
}
#2.定义配置NTP的函数
ntp_config(){
yum –y install chrony
systemctl start chronyd && systemctl enable chronyd
timedatectl set-timezone Asia/Shanghai && timedatectl set-ntp yes
}
#3.定义关闭防火墙的函数
close_firewalld(){
systemctl stop firewalld.service &> /dev/null 
systemctl disable firewalld.service &> /dev/null
}
#4.定义关闭selinux的函数
close_selinux(){
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config
}
#5.定义安装常用工具的函数
yum_tools(){
yum install –y vim wget curl curl-devel bash-completion lsof iotop iostat unzip bzip2 bzip2-devel
yum install –y gcc gcc-c++ make cmake autoconf openssl-devel openssl-perl net-tools
source /usr/share/bash-completion/bash_completion
}
#6.定义升级最新内核的函数
update_kernel (){
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-ml
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg
}
#执行脚本
main(){
    yum_config;
    ntp_config;
    close_firewalld;
    close_selinux;
    yum_tools;
    update_kernel;
}
main