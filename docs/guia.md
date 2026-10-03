# HOWTO – Configuração de IP e Roteamento no Debian 13

## 1. Cenário da atividade

Serão utilizadas duas máquinas virtuais:

### VM1 — NS1

| Interface | Tipo de rede | Configuração |
| --------- | ------------ | ------------ |
| `enp0s3` | NAT | DHCP |
| `enp0s8` | Rede Interna | `192.168.200.1/24` |

A VM1 será o **gateway da rede interna** e permitirá que a VM2 acesse a internet.

### VM2 — WEB

| Interface | Tipo de rede | Configuração |
| --------- | ------------ | ------------ |
| `enp0s3` | Rede Interna | `192.168.200.2/24` |

Gateway:

```text
192.168.200.1
```

DNS sugerido:

```text
8.8.8.8
```

O caminho da comunicação será:

```text
VM2 (WEB)
192.168.200.2
      |
      |
192.168.200.1
VM1 (NS1)
      |
   enp0s3
      |
    NAT
      |
  Internet
```

---

# Parte 1 — Configuração da VM1 (NS1)

## 2. Verificar as interfaces de rede

Na VM1 execute:

```bash
ip address
```

ou:

```bash
ip a
```

Verifique se aparecem as interfaces:

```text
enp0s3
enp0s8
```

Também é possível utilizar:

```bash
ip link
```

---

## 3. Configurar a rede da VM1

Edite o arquivo:

```bash
vim /etc/network/interfaces
```

No `vim`, pressione:

```text
i
```

para entrar no modo de inserção.

Configure da seguinte maneira:

```text
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet dhcp

auto enp0s8
iface enp0s8 inet static
    address 192.168.200.1/24
```

Para salvar e sair do `vim`:

1. Pressione `Esc`.
2. Digite:

```text
:wq
```

3. Pressione `Enter`.

A interface `enp0s3` receberá um endereço automaticamente do NAT do VirtualBox.

A interface `enp0s8` ficará com:

```text
192.168.200.1/24
```

---

## 4. Aplicar a configuração

A forma mais simples durante o laboratório é reiniciar a máquina:

```bash
reboot
```

Após reiniciar, faça login novamente e execute:

```bash
ip a
```

Deverá aparecer algo semelhante a:

```text
enp0s3:
    inet 10.0.2.15/24

enp0s8:
    inet 192.168.200.1/24
```

O endereço recebido em `enp0s3` pode ser diferente.

---

## 5. Verificar a rota da VM1

Execute:

```bash
ip route
```

Deverá existir uma rota padrão semelhante a:

```text
default via 10.0.2.2 dev enp0s3
```

E também:

```text
192.168.200.0/24 dev enp0s8
```

---

## 6. Testar o acesso à internet da VM1

Primeiramente teste usando um endereço IP:

```bash
ping -c 4 8.8.8.8
```

Depois teste resolução de nomes:

```bash
ping -c 4 google.com
```

A VM1 deve conseguir acessar a internet antes de continuar.

---

# Parte 2 — Habilitar o roteamento na VM1

## 7. Verificar se o encaminhamento IPv4 está habilitado

Execute:

```bash
sysctl net.ipv4.ip_forward
```

Provavelmente será exibido:

```text
net.ipv4.ip_forward = 0
```

O valor `0` significa que a máquina não está encaminhando pacotes entre interfaces.

---

## 8. Habilitar temporariamente o roteamento

Execute:

```bash
sysctl -w net.ipv4.ip_forward=1
```

Verifique novamente:

```bash
sysctl net.ipv4.ip_forward
```

Agora deverá aparecer:

```text
net.ipv4.ip_forward = 1
```

---

## 9. Tornar o roteamento permanente

Edite:

```bash
vim /etc/sysctl.conf
```

Pressione:

```text
i
```

Adicione ao final:

```text
net.ipv4.ip_forward=1
```

Para salvar e sair:

```text
Esc
:wq
Enter
```

Depois aplique a configuração:

```bash
sysctl -p
```

Verifique:

```bash
sysctl net.ipv4.ip_forward
```

A saída deverá ser:

```text
net.ipv4.ip_forward = 1
```

---

# Parte 3 — Configuração do NAT na VM1

## 10. Instalar o nftables

Execute:

```bash
apt update
```

Depois:

```bash
apt install nftables -y
```

Habilite o serviço:

```bash
systemctl enable nftables
```

---

## 11. Criar a configuração do nftables

Edite:

```bash
vim /etc/nftables.conf
```

Pressione:

```text
i
```

Utilize a seguinte configuração:

```text
#!/usr/sbin/nft -f

flush ruleset

table inet filter {

    chain forward {
        type filter hook forward priority 0;
        policy accept;
    }
}

table ip nat {

    chain postrouting {
        type nat hook postrouting priority srcnat;
        policy accept;

        ip saddr 192.168.200.0/24 oifname "enp0s3" masquerade
    }
}
```

Para salvar e sair:

```text
Esc
:wq
Enter
```

A regra:

```text
ip saddr 192.168.200.0/24 oifname "enp0s3" masquerade
```

faz com que os pacotes provenientes da rede `192.168.200.0/24`, quando saírem pela `enp0s3`, utilizem o endereço IP da própria VM1.

---

## 12. Verificar a sintaxe do arquivo

Antes de aplicar:

```bash
nft -c -f /etc/nftables.conf
```

Se não aparecer nenhum erro, carregue as regras:

```bash
nft -f /etc/nftables.conf
```

Reinicie o serviço:

```bash
systemctl restart nftables
```

---

## 13. Verificar as regras

Execute:

```bash
nft list ruleset
```

Deverá aparecer, entre outras informações:

```text
table ip nat {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 192.168.200.0/24 oifname "enp0s3" masquerade
    }
}
```

---

# Parte 4 — Configuração da VM2 (WEB)

## 14. Verificar a interface

Na VM2:

```bash
ip a
```

Confirme que a interface da rede interna é:

```text
enp0s3
```

---

## 15. Configurar o endereço IP da VM2

Edite:

```bash
vim /etc/network/interfaces
```

Pressione:

```text
i
```

Configure:

```text
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address 192.168.200.2/24
    gateway 192.168.200.1
```

Para salvar e sair:

```text
Esc
:wq
Enter
```

---

## 16. Aplicar a configuração

Reinicie:

```bash
reboot
```

Após iniciar novamente, execute:

```bash
ip a
```

Deverá aparecer:

```text
inet 192.168.200.2/24
```

---

# Parte 5 — Verificar o gateway

## 17. Verificar a tabela de roteamento da VM2

Execute:

```bash
ip route
```

Deverá aparecer aproximadamente:

```text
default via 192.168.200.1 dev enp0s3
192.168.200.0/24 dev enp0s3
```

A linha mais importante é:

```text
default via 192.168.200.1 dev enp0s3
```

Ela indica que qualquer destino que não pertença à rede local deverá ser enviado para a VM1.

---

# Parte 6 — Testes de comunicação

## 18. Testar VM2 → VM1

Na VM2 execute:

```bash
ping -c 4 192.168.200.1
```

O resultado esperado é semelhante a:

```text
64 bytes from 192.168.200.1: icmp_seq=1 ttl=64 time=...
```

---

## 19. Testar VM1 → VM2

Na VM1 execute:

```bash
ping -c 4 192.168.200.2
```

O resultado esperado é:

```text
64 bytes from 192.168.200.2: icmp_seq=1 ttl=64 time=...
```

Se ambos funcionarem, a comunicação da rede interna está configurada corretamente.

---

# Parte 7 — Testar o acesso à internet

## 20. Testar utilizando endereço IP

Na VM2:

```bash
ping -c 4 8.8.8.8
```

Se funcionar, significa que:

- o endereço IP está correto;
- o gateway está correto;
- o roteamento da VM1 está funcionando;
- o NAT está funcionando.

O caminho realizado é:

```text
192.168.200.2
      |
      v
192.168.200.1
      |
      v
   enp0s3
      |
      v
   Internet
```

---

# Parte 8 — Configurar DNS na VM2

Se:

```bash
ping -c 4 8.8.8.8
```

funcionar, mas:

```bash
ping -c 4 google.com
```

não funcionar, verifique:

```bash
cat /etc/resolv.conf
```

Para o laboratório, pode ser utilizado:

```text
nameserver 8.8.8.8
```

Edite:

```bash
vim /etc/resolv.conf
```

Pressione:

```text
i
```

Adicione:

```text
nameserver 8.8.8.8
```

Depois salve e saia:

```text
Esc
:wq
Enter
```

Teste novamente:

```bash
ping -c 4 google.com
```

---

# Parte 9 — Verificações finais

Na VM1:

```bash
ip a
```

```bash
ip route
```

```bash
sysctl net.ipv4.ip_forward
```

```bash
nft list ruleset
```

Na VM2:

```bash
ip a
```

```bash
ip route
```

```bash
ping -c 4 192.168.200.1
```

```bash
ping -c 4 8.8.8.8
```

```bash
ping -c 4 google.com
```

---

# Comandos básicos do Vim utilizados na atividade

Para editar os arquivos desta atividade, serão necessários apenas alguns comandos básicos.

Entrar no modo de inserção:

```text
i
```

Voltar para o modo normal:

```text
Esc
```

Salvar o arquivo:

```text
:w
```

Salvar e sair:

```text
:wq
```

Sair sem salvar:

```text
:q!
```

Portanto, o fluxo básico será:

```text
vim arquivo
```

Depois:

```text
i
```

Faça as alterações.

Em seguida:

```text
Esc
:wq
Enter
```

---

# Resumo das configurações

## VM1 — NS1

Arquivo:

```text
/etc/network/interfaces
```

Configuração:

```text
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet dhcp

auto enp0s8
iface enp0s8 inet static
    address 192.168.200.1/24
```

Roteamento:

```text
net.ipv4.ip_forward=1
```

NAT:

```text
ip saddr 192.168.200.0/24 oifname "enp0s3" masquerade
```

---

## VM2 — WEB

Arquivo:

```text
/etc/network/interfaces
```

Configuração:

```text
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address 192.168.200.2/24
    gateway 192.168.200.1
```

---

# O que deve aparecer no PDF da atividade

Os alunos deverão registrar prints dos seguintes testes:

### VM1

```bash
ip a
```

para demonstrar:

```text
enp0s8 → 192.168.200.1/24
```

### VM2

```bash
ip a
```

para demonstrar:

```text
enp0s3 → 192.168.200.2/24
```

### Gateway da VM2

```bash
ip route
```

para demonstrar:

```text
default via 192.168.200.1
```

### Comunicação entre as máquinas

Na VM2:

```bash
ping -c 4 192.168.200.1
```

### Acesso à internet

Na VM2:

```bash
ping -c 4 8.8.8.8
```

e:

```bash
ping -c 4 google.com
```

Com esses testes é possível comprovar a configuração completa da atividade.