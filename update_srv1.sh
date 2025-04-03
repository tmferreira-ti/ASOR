#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/sysctl.conf -O /etc/sysctl.conf --no-check-certificate --no-cache
#
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/nftables.conf -O /etc/nftables.conf --no-check-certificate --no-cache
sed -i s'/enp0s8/enp0s3/g' /usr/local/bin/sync-update
apt update
apt install ssh -y
wget https://raw.githubusercontent.com/tmferreira-ti/SSORI/refs/heads/main/configs/sshd_config -O /etc/ssh/sshd_config --no-check-certificate --no-cache

#apt install isc-dhcp-server -y
#wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/refs/heads/main/Confs/srv1/dhcpd.conf -O /etc/dhcp/dhcpd.conf --no-check-certificate --no-cache
#wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/refs/heads/main/Confs/srv1/isc-dhcp-server -O /etc/default/isc-dhcp-server --no-check-certificate --no-cache

systemctl enable nftables
#reboot

#apt install bind9 -y

#wget github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv1/dns/named.conf.options -O /etc/bind/named.conf.options

#wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv1/dns/named.conf.local -O /etc/bind/named.conf.local --no-check-certificate --no-cache

#mkdir -p /etc/bind/domains/fatecseg/

#wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv1/dns/db.fatecseg.edu.br -O /etc/bind/domains/fatecseg/db.fatecseg.edu.br --no-check-certificate --no-cache

#wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv1/dns/db.0.17.172 -O /etc/bind/domains/fatecseg/db.0.17.172 --no-check-certificate --no-cache

#echo "domain fatecseg.edu.br" > /etc/resolv.conf
#echo "search fatecseg.edu.br"  >> /etc/resolv.conf
#echo "nameserver 172.17.0.1" >> /etc/resolv.conf
#echo "nameserver 172.17.0.2" >> /etc/resolv.conf

#chattr +i /etc/resolv.conf

#systemctl restart named
reboot
