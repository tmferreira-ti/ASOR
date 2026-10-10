# HOWTO — Configuração do Serviço DHCP

Este guia configura a **VM1 (NS1)** para fornecer endereços IP automaticamente aos dispositivos conectados à rede interna do VirtualBox.

## 1. Cenário do laboratório

| Parâmetro | Configuração |
| --- | --- |
| Servidor DHCP | VM1 — NS1 |
| Interface da rede interna | `enp0s8` |
| Rede | `192.168.200.0/24` |
| Faixa dinâmica | `192.168.200.100` até `192.168.200.150` |
| Gateway | `192.168.200.1` |
| Servidores DNS | `192.168.200.1` e `192.168.200.2` |

Antes de começar, confirme que a interface `enp0s8` da VM1 possui o endereço estático `192.168.200.1/24`.

```bash
ip address show enp0s8
```

A saída deve mostrar uma linha semelhante a:

```text
inet 192.168.200.1/24
```

---

# Parte 1 — Instalação do serviço

## 2. Atualizar a lista de pacotes

```bash
apt update
```

## 3. Instalar o ISC DHCP Server

```bash
apt install isc-dhcp-server -y
```

Durante a instalação, o serviço pode apresentar falha por ainda não possuir uma configuração válida. Isso será corrigido nas próximas etapas.

---

# Parte 2 — Configuração do DHCP

## 4. Criar uma cópia de segurança

```bash
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
```

## 5. Editar o arquivo dhcpd.conf

Abra o arquivo principal do serviço:

```bash
vim /etc/dhcp/dhcpd.conf
```

Pressione `i` para entrar no modo de inserção. Apague o conteúdo existente e utilize a configuração abaixo:

```text
# Arquivo de configuração do servidor DHCP

# Desabilita as atualizações dinâmicas de DNS
ddns-update-style none;

# Tempo padrão de concessão: 10 minutos
default-lease-time 600;

# Tempo máximo de concessão: 2 horas
max-lease-time 7200;

# Este servidor é autoritativo para a rede interna
authoritative;

# Rede interna do laboratório
subnet 192.168.200.0 netmask 255.255.255.0 {

    # Endereços que poderão ser entregues aos clientes
    range 192.168.200.100 192.168.200.150;

    # Gateway padrão fornecido aos clientes
    option routers 192.168.200.1;

    # Servidores DNS fornecidos aos clientes
    option domain-name-servers 192.168.200.1, 192.168.200.2;

    # Endereço de broadcast da rede
    option broadcast-address 192.168.200.255;
}
```

Para salvar e sair do Vim, pressione `Esc`, digite `:wq` e pressione `Enter`.

## 6. Entender os parâmetros principais

| Diretiva | Função |
| --- | --- |
| `subnet` | Identifica a rede atendida pelo servidor. |
| `range` | Define os endereços disponíveis para concessão dinâmica. |
| `option routers` | Informa aos clientes qual é o gateway padrão. |
| `option domain-name-servers` | Informa os servidores usados para resolução de nomes. |
| `option broadcast-address` | Define o endereço de broadcast da rede. |
| `authoritative` | Declara que este é o servidor DHCP oficial da rede. |

---

# Parte 3 — Interface atendida pelo serviço

## 7. Configurar a interface enp0s8

Abra o arquivo de inicialização do serviço:

```bash
vim /etc/default/isc-dhcp-server
```

Localize as variáveis de interfaces e deixe-as assim:

```text
INTERFACESv4="enp0s8"
INTERFACESv6=""
```

Essa configuração impede que o servidor DHCP atenda pela interface `enp0s3`, ligada ao NAT do VirtualBox, e limita o serviço à rede interna.

---

# Parte 4 — Validação e inicialização

## 8. Verificar a sintaxe da configuração

Antes de reiniciar o serviço, valide o arquivo:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Se o comando não exibir erros, a sintaxe está correta. Caso apareça uma mensagem com número de linha, volte ao arquivo e corrija o trecho indicado.

## 9. Reiniciar o serviço DHCP

```bash
systemctl restart isc-dhcp-server
```

Quando o comando for executado com sucesso, ele normalmente não apresenta nenhuma saída.

## 10. Verificar o estado do serviço

```bash
systemctl status isc-dhcp-server
```

Procure pela indicação:

```text
Active: active (running)
```

Pressione `q` para sair da tela de status.

## 11. Habilitar a inicialização automática

```bash
systemctl enable isc-dhcp-server
```

---

# Parte 5 — Testes e diagnóstico

## 12. Acompanhar os registros do serviço

Para visualizar as mensagens mais recentes:

```bash
journalctl -u isc-dhcp-server -n 30 --no-pager
```

Para acompanhar novas solicitações DHCP em tempo real:

```bash
journalctl -u isc-dhcp-server -f
```

Use `Ctrl+C` para encerrar o acompanhamento.

## 13. Testar com a VM3 — CLIENTE

Conecte a interface `enp0s3` da VM3 à mesma Rede Interna do VirtualBox usada pelas interfaces `enp0s8` da VM1 e `enp0s3` da VM2. Configure a interface da cliente para usar DHCP.

Na cliente, solicite uma concessão:

```bash
dhclient -v enp0s3
```

Depois, confira o endereço e a rota recebidos:

```bash
ip address show enp0s3
ip route
```

O endereço da interface deve estar entre `192.168.200.100` e `192.168.200.150`, e a rota padrão deve usar `192.168.200.1` como gateway.

## 14. Verificar as concessões no servidor

Na VM1, consulte o arquivo de concessões:

```bash
cat /var/lib/dhcp/dhcpd.leases
```

Também é possível filtrar os eventos DHCP nos registros:

```bash
journalctl -u isc-dhcp-server --no-pager | grep -E "DHCPDISCOVER|DHCPOFFER|DHCPREQUEST|DHCPACK"
```

---

# Parte 6 — Solução de problemas

## 15. O serviço não inicia

Execute novamente a validação e consulte os registros:

```bash
dhcpd -t -cf /etc/dhcp/dhcpd.conf
journalctl -u isc-dhcp-server -n 50 --no-pager
```

Confira principalmente pontos e vírgulas, chaves, endereços da rede e o nome da interface.

## 16. A cliente não recebe endereço

- Confirme se as máquinas usam a mesma Rede Interna no VirtualBox.
- Verifique se a VM1 mantém `192.168.200.1/24` em `enp0s8`.
- Confirme `INTERFACESv4="enp0s8"`.
- Verifique se o serviço está como `active (running)`.
- Certifique-se de que não exista outro servidor DHCP ativo na mesma rede interna.

---

# Parte 7 — Preparação da entrega

Organize um único arquivo PDF com o nome completo dos integrantes e capturas legíveis dos itens solicitados.

## 17. Configuração do DHCP

Exiba o conteúdo de `/etc/dhcp/dhcpd.conf` de maneira que a rede, a faixa, o gateway e os servidores DNS estejam visíveis.

```bash
cat /etc/dhcp/dhcpd.conf
```

## 18. Reinicialização do serviço

Registre a execução bem-sucedida:

```bash
systemctl restart isc-dhcp-server
```

## 19. Serviço ativo

Registre a tela que apresenta `Active: active (running)`:

```bash
systemctl status isc-dhcp-server
```

Revise se todas as capturas estão legíveis antes de gerar o PDF final.
