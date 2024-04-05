#!/bin/bash
apt autoremove --purge bind9 -y
rm -rf /etc/bind
apt install bind9 -y
chattr -i /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt install bind9 -y
wget https://bit.ly/4cLIEjT -O /etc/bind/named.conf.options
wget https://bit.ly/3J5pKH9 -O /etc/bind/named.conf.local
mkdir -p /etc/bind/domains/fatecseg/
wget https://bit.ly/3J4JE5l -O /etc/bind/domains/fatecseg/db.200.168.192
wget https://bit.ly/3VLnfBk -O /etc/bind/domains/fatecseg/db.fatecseg.edu.br
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/resolv.conf -O /tmp/resolv.conf --no-check
mv /tmp/resolv.conf /etc/resolv.conf
chattr +i /etc/resolv.conf
systemctl restart bind9
