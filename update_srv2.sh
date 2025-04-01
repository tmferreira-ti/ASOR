#!/bin/bash
wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Confs/srv2/interfaces -O /etc/network/interfaces --no-check-certificate --no-cache
#wget https://raw.githubusercontent.com/tmferreira-ti/SSORI/refs/heads/main/configs/sshd_config -O /etc/ssh/sshd_config --no-check-certificate --no-cache

#apt install bind9 -y

#wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv2/dns/named.conf.options -O /etc/bind/named.conf.options

#wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv2/dns/named.conf.local -O /etc/bind/named.conf.local --no-check-certificate --no-cache

#apt update

#apt install apache2 -y

#apt install mariadb-server -y 

#apt install php php-mysql libapache2-mod-php php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc -y

#wget https://github.com/tmferreira-ti/ASOR/raw/refs/heads/main/Confs/srv2/Apache/fatecseg.conf -O /etc/apache2/sites-available/site.conf --no-check-certificate --no-cache

#mkdir /dados/paginas/fatecseg -p

#a2ensite site.conf

#a2dissite 000-default.conf

#mysql -u root -p -e "CREATE DATABASE wordpress;"
#mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
#mysql -u root -p -e "FLUSH PRIVILEGES;"


#cd /dados/paginas/fatecseg/

#rm -f index.html

#wget wordpress.org/latest.tar.gz

#tar --strip-components=1 -xzvf latest.tar.gz

#rm -f latest.tar.gz

#chown www-data: -R /dados/paginas/fatecseg/

reboot
