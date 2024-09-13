#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/sysctl.conf -O /etc/sysctl.conf --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv1/nftables.conf -O /etc/nftables.conf --no-check-certificate --no-cache

systemctl enable nftables
reboot
