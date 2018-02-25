#!/bin/bash
#变量存储
#myip=`curl -s http://members.3322.org/dyndns/getip`
#IP=`curl -s http://members.3322.org/dyndns/getip`
echo "请选择你对接面板方式 glzjinmod, modwebapi"
read APIFS
if [[ -z $APIFS ]]
	then
		APIFS=glzjinmod
	fi
fi
	if [[ $APIFS == glzjinmod ]]
		echo "请输入数据库服务器地址"
			read MYSQLFWQ
			if [[ -z $MYSQLFWQ ]]
				then
				MYSQLFWQ=1
			fi
		echo "请输入数据库服务器端口"
			read FWQDK
			if [[ -z $FWQDK ]]
				then
				FWQDK=1
			fi
		echo "请输入数据库用户"
			read SQLUSER
			if [[ -z $SQLUSER ]]
				then
				SQLUSER=1
			fi
		echo "请输入数据库密码"
			read SQLPASS
			if [[ -z $SQLPASS ]]
				then
				SQLPASS=1
			fi
		echo "请输入数据库名"
			read SQLDB
			if [[ -z $SQLDB ]]
				then
				SQLDB=1
			fi
	then
		echo "请输入接口密钥"
			read WEBKEY
			if [[ -z $WEBKEY ]]
				then
				WEBKEY=1
			fi
	fi

	echo "请输入服务器ID："
		read FWQID
		if [[ -z $FWQID ]]
			then
			FWQID=80
		fi
	echo "请输入面板服务器地址举例：https://baidu.com"
		read WEBAPIJK
		if [[ -z $WEBAPIJK ]]
		then
			WEBAPIJK=1
		fi
#处理残留环境
echo "安装依赖包，喝杯咖啡歇息一下吧！不要乱动哦，别按回车"

yum clean all
yum makecache
	#安装
	yum install unzip curl  zip tar expect crontabs git wget iptables-services net-tools -y
	mkdir -p /var/spool/cron/ >/dev/null 2>&1
	yum install -y redhat-lsb gawk httpd-devel psmisc glibc-static expect 
	yum install -y gcc gcc-c++ openssl openssl-devel automake
	yum install -y gcc automake autoconf libtool make build-essential curl curl-devel zlib-devel openssl-devel perl perl-devel cpio expat-devel gettext-devel git asciidoc xmlto
	#防止暴力破解
	cd /root/
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	yum install fail2ban -y
	service fail2ban restart
	chkconfig fail2ban on
	#加密支持库安装
	yum install python-setuptools  -y && easy_install pip  >/dev/null 2>&1
	yum install python-devel libffi-devel -y >/dev/null 2>&1
	yum -y groupinstall "Development Tools"
	wget -N --no-check-certificate https://github.com/jedisct1/libsodium/releases/download/1.0.15/libsodium-1.0.15.tar.gz
	tar xf libsodium-1.0.15.tar.gz && cd libsodium-1.0.15
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	cd
	#时间同步
	echo;echo -e "\033[1;36m正在同步时间...\033[0m"
	systemctl stop ntpd.service >/dev/null 2>&1
	service ntpd stop >/dev/null 2>&1
	\cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime >/dev/null 2>&1
	ntpServer=(
		[0]=cn.ntp.org.cn
		[1]=s2c.time.edu.cn
		[2]=s1a.time.edu.cn
		[3]=s2g.time.edu.cn
		[4]=s2k.time.edu.cn
		[5]=s2m.time.edu.cn
		)
	serverNum=`echo ${#ntpServer[*]}`
	NUM=0
	for (( i=0; i<=$serverNum; i++ )); do
		echo -en " 正在和NTP服务器 \033[34m${ntpServer[$NUM]} \033[0m 同步中..." >/dev/null 2>&1
		ntpdate ${ntpServer[$NUM]} >> /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo -e "\t\t\t[  \e[1;32mOK\e[0m  ]" >/dev/null 2>&1
			echo;echo -e "\033[1;33m当前时间：\033[0m\033[1;36m$(date -d "2 second" +"%Y-%m-%d %H:%M:%S")\033[0m"
			break
		else
			echo -e "\t\t\t[  \e[1;31mERROR\e[0m  ]" >/dev/null 2>&1
			let NUM++
		fi
		sleep 1
	done
	hwclock --systohc
	systemctl start ntpd.service >/dev/null 2>&1
	service ntpd start >/dev/null 2>&1
	echo;echo -e "\033[1;35m时间同步完毕...\033[0m"
	#防火墙
	echo "配置防火墙"
	iptables -F
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	iptables -F
	servcie iptables stop
	chkconfig iptables off
	setenforce 0
	echo "/usr/sbin/setenforce 0" >> /etc/rc.local
	echo "放行各种端口"
	sleep 3
	#导入SSR主程序
	supervisorctl stop ssr
	rm -rf Geek
	wget -N --no-check-certificate https://raw.githubusercontent.com/geekvpn/P-Other/master/Geek.zip
	unzip Geek.zip
	rm -rf Geek.zip
	cd Geek
	pip install -r requirements.txt
	sed -i "s/FWQID/$FWQID/g" /root/Geek/userapiconfig.py
	sed -i "s/APIFS/$APIFS/g" /root/Geek/userapiconfig.py
	sed -i "s/WEBAPIJK/$WEBAPIJK/g" /root/Geek/userapiconfig.py
	sed -i "s/MYSQLFWQ/$MYSQLFWQ/g" /root/Geek/userapiconfig.py
	sed -i "s/FWQDK/$FWQDK/g" /root/Geek/userapiconfig.py
	sed -i "s/SQLUSER/$SQLUSER/g" /root/Geek/userapiconfig.py
	sed -i "s/SQLPASS/$SQLPASS/g" /root/Geek/userapiconfig.py
	sed -i "s/SQLDB/$SQLDB/g" /root/Geek/userapiconfig.py
	sed -i "s/YOUWEB/$WEBAPIJK/g" /root/Geek/detect.html
	chmod 777 -R *
	
	#守护SSR进程
	pip install supervisor
	rm -rf /etc/supervisord.conf
	cd /etc/
	wget -N --no-check-certificate https://raw.githubusercontent.com/geekvpn/P-Other/master/supervisord.conf
	cd
	#重启命令
	echo "echo ReStart Ing...
	supervisord -c /etc/supervisord.conf
	echo ok
	exit 0;
	" >/bin/SSR
	chmod 777 /bin/SSR


	chmod +x /etc/rc.d/rc.local
	sed -i '$a \SSR' /etc/rc.d/rc.local  >/dev/null 2>&1
	rm -rf /etc/sysctl.conf
	echo '# Kernel sysctl configuration file for Red Hat Linux
	# by kangml.com
	# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and
	# sysctl.conf(5) for more details.

	# Controls IP packet forwarding
	net.ipv4.ip_forward = 1

	# Controls source route verification
	net.ipv4.conf.default.rp_filter = 1

	# Do not accept source routing
	net.ipv4.conf.default.accept_source_route = 0

	# Controls the System Request debugging functionality of the kernel
	kernel.sysrq = 0

	# Controls whether core dumps will append the PID to the core filename.
	# Useful for debugging multi-threaded applications.
	kernel.core_uses_pid = 1

	# Controls the use of TCP syncookies
	net.ipv4.tcp_syncookies = 1

	# Disable netfilter on bridges.
	net.bridge.bridge-nf-call-ip6tables = 0
	net.bridge.bridge-nf-call-iptables = 0
	net.bridge.bridge-nf-call-arptables = 0

	# Controls the default maxmimum size of a mesage queue
	kernel.msgmnb = 65536

	# Controls the maximum size of a message, in bytes
	kernel.msgmax = 65536

	# Controls the maximum shared segment size, in bytes
	kernel.shmmax = 68719476736

	# Controls the maximum number of shared memory segments, in pages
	kernel.shmall = 4294967296
	' >/etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	rm -rf /root/ok.sh
	echo -e '服务状态：  [\033[32m  OK  \033[0m]'
	echo OK
	SSR