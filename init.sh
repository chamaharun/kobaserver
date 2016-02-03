set -eu
dist=`cat /etc/issue | head -n 1 | perl -ne '$_=~s/^(\w*)\s(.*)$/$1/g;print $_'`

apikey=""

echo "Input Hostname：(.charakoba.com)"
read hostname
echo "Input IP Address"
read ipaddress


#Set HostName
cat<<EOF > /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=${hostname}.charakoba.com
GATEWAY=192.168.11.1
EOF


 if [ "$dist" = 'CentOS' ];then
 	echo "遷都！"
 	selinux=`getenforce`
    #Script for CentOS

    #Set IP Address
    
cat<<EOF > /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE="eth0"
BOOTPROTO="static"
BROADCAST="192.168.11.255" 
IPADDR=${ipaddress}
DNS1="192.168.11.2"
DNS2="192.168.11.1"
GATEWAY="192.168.11.1"
NETMASK="255.255.255.0"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Ethernet"
EOF
    service network restart

#disable SElinux
if [ "$selinux" = 'Enforcing' ];then
    sed -i -E "s/^SELINUX=enforcing$/SELINUX=permissive/g" /etc/sysconfig/selinux
    SELINUX=enforcing	
fi

echo "include_only=.jp" >> /etc/yum/pluginconf.d/fastestmirror.conf

#yum epel repo add
yum -y install epel-release
yum -y install vim git tmux

    
 
elif [ "$dist" = 'Ubuntu' ];then
	echo "うぶんつ！"
	#Script for Ubuntu
	
cat <<EOF > /etc/network/interfaces

auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address ${ipaddress}
netmask 255.255.255.0
gateway 192.168.11.1
dns-nameservers 192.168.11.2


EOF


 fi	

curl http://ns.charakoba.com --request POST --data mode=add --data ip=${ipaddress} --data host=${hostname} --data apikey=${apikey}


reboot
