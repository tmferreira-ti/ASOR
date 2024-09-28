#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/sysctl.conf -O /etc/sysctl.conf --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/nftables.conf -O /etc/nftables.conf --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/SSORI/refs/heads/main/configs/sshd_config -O /etc/ssh/sshd_config --no-check-certificate --no-cache

apt install isc-dhcp-server -y
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/refs/heads/main/Confs/srv1/dhcpd.conf -O /etc/dhcp/dhcpd.conf --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/refs/heads/main/Confs/srv1/isc-dhcp-server -O /etc/default/isc-dhcp-server --no-check-certificate --no-cache

systemctl enable nftables
reboot
