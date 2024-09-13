#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv2/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
reboot
