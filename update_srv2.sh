#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv2/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/SSORI/refs/heads/main/configs/sshd_config -O /etc/ssh/sshd_config --no-check-certificate --no-cache

apt install bind9 -y

wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv2/dns/named.conf.options -O /etc/bind/named.conf.options

wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv2/dns/named.conf.local -O /etc/bind/named.conf.local --no-check-certificate --no-cache

apt update

apt install apache2

reboot
