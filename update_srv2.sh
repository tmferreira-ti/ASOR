#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv2/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
wget https://raw.githubusercontent.com/tmferreira-ti/SSORI/refs/heads/main/configs/sshd_config -O /etc/ssh/sshd_config --no-check-certificate --no-cache
reboot
