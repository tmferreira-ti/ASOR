#!/bin/bash
clear
echo "
1 - ASOR-ROUTER
2 - ASOR-AD
3 - ASOR-WEB
4 - ASOR-NS1
5 - ASOR-NS2
"
read -p "Informe em qual máquina esse script será executado: " opcao

case $opcao in 
	1)
		echo router
	;;

	2)
		echo AD
	;;

	3)
		echo WEB
	;;

	4)
		echo NS1
	;;

	5)
		echo NS2
	;;

	*)
		echo "Opção inválida, digite uma opção válida."
	;;
esac


