#!/bin/bash

# Definição de cores para formatação
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"
BOLD="\e[1m"

clear
echo -e "${BOLD}${CYAN}####### Script de Diagnóstico de Configuração #######${RESET}"

read -e -p "Digite os três primeiros octetos do seu IP [192.168.]: " -i "192.168." IP
#read -e -p "Digite o seu domínio: " DOMAIN
clear

echo -e "${BOLD}${CYAN}####### Data de Instalação WEB #######${RESET}"
echo -e "${YELLOW}$(tune2fs -l /dev/sda1 | grep created | awk '{print $5"/"$4"/"$7" "$6}')${RESET}"
read -p "Pressione <Enter> para continuar..."

clear
echo -e "${BOLD}${CYAN}####### Configuração de Rede #######${RESET}"
ip -br addr | egrep -v ^lo
read -p "Pressione <Enter> para continuar..."

clear
echo -e "${BOLD}${CYAN}####### Conectividade com a Máquina NS1 #######${RESET}"
if ping -c1 "$IP.1" > /dev/null; then
  echo -e "${GREEN}Conectividade Ok${RESET}"
else
  echo -e "${RED}Conectividade não Ok${RESET}"
fi
read -p "Pressione <Enter> para continuar..."

clear
echo -e "${BOLD}${CYAN}####### Conectividade com a Internet #######${RESET}"
for server in 8.8.8.8 1.1.1.1; do
  if ping -c1 "$server" > /dev/null; then
    echo -e "${GREEN}Conectividade $server: Ok${RESET}"
  else
    echo -e "${RED}Conectividade $server: Não Ok${RESET}"
  fi
done
read -p "Pressione <Enter> para continuar..."

clear
echo -e "${BOLD}${CYAN}####### Serviço Apache  #######${RESET}"
systemctl status apache2 --no-pager
read -p "Pressione <Enter> para continuar..."
clear


