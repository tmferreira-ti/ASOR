#!/bin/bash

# Função para a configuração do roteador
configurar_router() {
    echo "Configurando o roteador..."
    # Adicione aqui os comandos para configurar o roteador
    chattr -i /etc/resolv.conf
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    apt install isc-dhcp-server -y
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Router/dhcp/dhcpd.conf -O /etc/dhcp/dhcpd.conf
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Router/dhcp/isc-dhcp-server -O /etc/default/isc-dhcp-server
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Router/interfaces/interfaces -O /etc/network/interfaces
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/Router/nftables.conf -O /etc/nftables.conf
    echo "nameserver 192.168.200.2" > /etc/resolv.conf
    echo "nameserver 192.168.200.3" >> /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    chattr +i /etc/resolv.conf
    systemctl restart networking.service
    systemctl restart isc-dhcp-server.service
    systemctl enable nftables
    systemctl restart nftables
    sed -i '28s/^#//' /etc/sysctl.conf
    sysctl -p
}

# Função para a configuração do Active Directory (AD)
configurar_ad() {
    echo "Configurando o Active Directory (AD)..."
    # Adicione aqui os comandos para configurar o AD
}

# Função para a configuração do servidor de nomes 1 (NS1)
configurar_ns1() {
    echo "Configurando o servidor de nomes 1 (NS1)..."
    # Adicione aqui os comandos para configurar o NS1
    chattr -i /etc/resolv.conf
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    apt install bind9 -y
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/DNS/Master/named.conf.options -O /etc/bind/named.conf.options
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/DNS/Master/named.conf.local -O /etc/bind/named.conf.local
    mkdir -p /etc/bind/domains/fatecseg/
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/DNS/Master/db.fatecseg.edu.br -O /etc/bind/domains/fatecseg/db.fatecseg.edu.br
    wget https://raw.githubusercontent.com/tmferreira-ti/ASOR/main/DNS/Master/db.200.168.192 -O /etc/bind/domains/fatecseg/db.200.168.192
    echo "nameserver 192.168.200.2" > /etc/resolv.conf
    echo "nameserver 192.168.200.3" >> /etc/resolv.conf
    chattr +i /etc/resolv.conf
    systemctl restart bind9
    
}

# Função para a configuração do servidor de nomes 2 (NS2)
configurar_ns2() {
    echo "Configurando o servidor de nomes 2 (NS2)..."
    # Adicione aqui os comandos para configurar o NS2
}

# Função para a configuração do servidor web
configurar_web() {
    echo "Configurando o servidor web..."
    # Adicione aqui os comandos para configurar o servidor web
}

# Verifica o primeiro parâmetro e chama a função correspondente
case "$1" in
    router)
        configurar_router
        ;;
    ad)
        configurar_ad
        ;;
    ns1)
        configurar_ns1
        ;;
    ns2)
        configurar_ns2
        ;;
    web)
        configurar_web
        ;;
    *)
        echo "Uso: $0 {router|ad|ns1|ns2|web}"
        exit 1
        ;;
esac

exit 0

