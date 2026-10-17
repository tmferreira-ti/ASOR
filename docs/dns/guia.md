# HOWTO — Configuração do Serviço DNS

Este guia configura o **BIND9** em duas máquinas Debian 13: a **VM1 (NS1)** será o servidor DNS primário e a **VM2 (WEB/NS2)** será o servidor DNS secundário do domínio `fatectech.com.br`.

## 1. Cenário do laboratório

| Função | Máquina | Endereço IP | Tipo da zona |
| --- | --- | --- | --- |
| DNS primário | VM1 — NS1 | `192.168.200.1` | `master` |
| DNS secundário | VM2 — WEB/NS2 | `192.168.200.2` | `slave` |
| Domínio | — | `fatectech.com.br` | Zona direta |

O arquivo original da zona será criado **somente na VM1**. A VM2 receberá sua cópia automaticamente por transferência de zona.

Antes de começar, confirme os endereços das duas máquinas e a comunicação entre elas:

```bash
ip -br address
ping -c 4 192.168.200.1
ping -c 4 192.168.200.2
```

> Execute os comandos da VM1 no servidor `192.168.200.1` e os comandos da VM2 no servidor `192.168.200.2`. Use uma sessão de terminal como `root` ou acrescente `sudo` aos comandos administrativos.

---

# Parte 1 — Instalação do BIND9

## 2. Instalar os pacotes nas duas VMs

Execute na **VM1 e na VM2**:

```bash
apt update
apt install bind9 bind9-utils dnsutils -y
```

O pacote `bind9` instala o servidor DNS. `bind9-utils` fornece as ferramentas de validação e `dnsutils` fornece o comando `dig` usado nos testes.

No Debian 13, o processo do BIND9 e sua unidade do systemd usam o nome `named`. Por isso, os comandos de serviço deste guia utilizam `systemctl ... named`.

## 3. Conferir os arquivos principais

O arquivo `/etc/bind/named.conf` inclui os arquivos usados neste laboratório:

| Arquivo | Finalidade |
| --- | --- |
| `/etc/bind/named.conf.local` | Declara as zonas atendidas pelo servidor. |
| `/etc/bind/named.conf.options` | Define opções gerais do BIND9. |
| `/etc/bind/domains/fatectech/db.fatectech.com.br` | Armazena os registros originais na VM1. |
| `/var/lib/bind/db.fatectech.com.br` | Recebe automaticamente a cópia da zona na VM2. |

---

# Parte 2 — DNS primário na VM1

## 4. Criar o diretório e o arquivo da zona

Na **VM1 (NS1)**, crie o diretório:

```bash
mkdir -p /etc/bind/domains/fatectech
```

Abra o arquivo da zona:

```bash
vim /etc/bind/domains/fatectech/db.fatectech.com.br
```

Pressione `i`, insira exatamente a configuração abaixo e depois use `Esc`, `:wq` e `Enter` para salvar:

```text
$TTL 3600
@   IN  SOA ns1.fatectech.com.br. hostmaster.fatectech.com.br. (
        2026101701 ; serial — altere sempre que editar a zona
        28800      ; refresh — 8 horas
        7200       ; retry — 2 horas
        604800     ; expire — 7 dias
        7200 )     ; negative cache TTL — 2 horas

; Servidores autoritativos
@       IN  NS      ns1.fatectech.com.br.
@       IN  NS      ns2.fatectech.com.br.

; Servidor de e-mail
@       IN  MX  10  smtp.fatectech.com.br.

; Registros IPv4
ns1     IN  A       192.168.200.1
ns2     IN  A       192.168.200.2
www     IN  A       192.168.200.2
blog    IN  A       192.168.200.2
smtp    IN  A       192.168.200.1

; Alias
revista IN  CNAME   www.fatectech.com.br.
```

Os pontos finais em `ns1.fatectech.com.br.`, `ns2.fatectech.com.br.`, `smtp.fatectech.com.br.` e `www.fatectech.com.br.` indicam nomes completos. Sem o ponto, o BIND acrescentaria o nome da zona novamente.

## 5. Entender os registros criados

| Tipo | Nome | Resultado |
| --- | --- | --- |
| `SOA` | `fatectech.com.br` | Identifica a autoridade da zona e seu número de série. |
| `NS` | `fatectech.com.br` | Publica `ns1` e `ns2` como servidores autoritativos. |
| `A` | `ns1` | Resolve para `192.168.200.1`. |
| `A` | `ns2`, `www` e `blog` | Resolvem para `192.168.200.2`. |
| `A` | `smtp` | Resolve para `192.168.200.1`. |
| `MX` | `fatectech.com.br` | Aponta para `smtp.fatectech.com.br` com prioridade 10. |
| `CNAME` | `revista` | Cria um alias para `www.fatectech.com.br`. |

## 6. Declarar a zona primária

Faça uma cópia de segurança e abra a configuração local:

```bash
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bkp
vim /etc/bind/named.conf.local
```

Adicione:

```text
zone "fatectech.com.br" IN {
    type master;
    file "/etc/bind/domains/fatectech/db.fatectech.com.br";
    allow-transfer { 192.168.200.2; };
    also-notify { 192.168.200.2; };
};
```

`allow-transfer` restringe a transferência ao endereço da VM2. `also-notify` avisa a VM2 quando a zona é atualizada.

## 7. Ajustar as permissões do arquivo

```bash
chown root:bind /etc/bind/domains/fatectech/db.fatectech.com.br
chmod 640 /etc/bind/domains/fatectech/db.fatectech.com.br
```

---

# Parte 3 — Validar e iniciar o DNS primário

## 8. Validar a configuração da VM1

Verifique todos os arquivos incluídos pelo BIND9:

```bash
named-checkconf
```

O comando não mostra saída quando a sintaxe está correta. Em seguida, valide a zona:

```bash
named-checkzone fatectech.com.br /etc/bind/domains/fatectech/db.fatectech.com.br
```

O resultado esperado termina com `OK` e informa o mesmo serial definido no arquivo.

## 9. Reiniciar e verificar o serviço na VM1

```bash
systemctl restart named
systemctl enable named
systemctl status named --no-pager
```

Procure por `Active: active (running)`. Confirme também que o servidor está ouvindo na porta 53:

```bash
ss -lntup | grep ':53'
```

O DNS utiliza **UDP 53** nas consultas usuais e **TCP 53** em operações como a transferência de zona. Caso exista um firewall na VM1, permita os dois protocolos entre as máquinas da rede interna.

## 10. Testar o servidor primário

```bash
dig @192.168.200.1 ns1.fatectech.com.br A +noall +answer
dig @192.168.200.1 www.fatectech.com.br A +noall +answer
dig @192.168.200.1 fatectech.com.br MX +noall +answer
dig @192.168.200.1 fatectech.com.br NS +noall +answer
dig @192.168.200.1 revista.fatectech.com.br CNAME +noall +answer
```

As respostas devem reproduzir os registros do arquivo da zona.

---

# Parte 4 — DNS secundário na VM2

## 11. Declarar a zona secundária

Na **VM2 (WEB/NS2)**, faça uma cópia de segurança e abra o arquivo:

```bash
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bkp
vim /etc/bind/named.conf.local
```

Adicione:

```text
zone "fatectech.com.br" IN {
    type slave;
    file "/var/lib/bind/db.fatectech.com.br";
    masters { 192.168.200.1; };
};
```

Não crie nem edite manualmente `/var/lib/bind/db.fatectech.com.br`. O BIND9 da VM2 criará esse arquivo ao receber a zona da VM1.

## 12. Validar e iniciar o DNS secundário

```bash
named-checkconf
systemctl restart named
systemctl enable named
systemctl status named --no-pager
```

Confirme `Active: active (running)` e verifique a porta 53:

```bash
ss -lntup | grep ':53'
```

## 13. Confirmar o recebimento da zona

Ainda na VM2, verifique se o arquivo foi criado:

```bash
ls -lh /var/lib/bind/db.fatectech.com.br
```

Confira o estado carregado pelo BIND9:

```bash
rndc zonestatus fatectech.com.br
```

Se precisar consultar as mensagens da transferência:

```bash
journalctl -u named -n 50 --no-pager
```

---

# Parte 5 — Testes de resolução e transferência

## 14. Consultar diretamente o servidor secundário

```bash
dig @192.168.200.2 ns2.fatectech.com.br A +noall +answer
dig @192.168.200.2 www.fatectech.com.br A +noall +answer
dig @192.168.200.2 blog.fatectech.com.br A +noall +answer
dig @192.168.200.2 fatectech.com.br MX +noall +answer
dig @192.168.200.2 fatectech.com.br NS +noall +answer
dig @192.168.200.2 revista.fatectech.com.br CNAME +noall +answer
```

Essas consultas devem apresentar os mesmos valores retornados pela VM1.

## 15. Comparar o serial nos dois servidores

```bash
dig @192.168.200.1 fatectech.com.br SOA +short
dig @192.168.200.2 fatectech.com.br SOA +short
```

O primeiro número depois do contato `hostmaster.fatectech.com.br.` é o serial. Os dois servidores devem mostrar o mesmo valor.

## 16. Testar a transferência de zona

Execute este comando **na VM2**, para que a solicitação saia do endereço autorizado `192.168.200.2`:

```bash
dig @192.168.200.1 fatectech.com.br AXFR
```

A resposta deve listar os registros da zona e terminar com o registro SOA. Esse teste comprova que a VM1 permite a transferência para a VM2.

## 17. Validar uma atualização da zona

Na VM1, edite o arquivo de zona, faça a alteração necessária e **aumente o serial**. Por exemplo, depois de `2026101701`, use `2026101702`.

Valide e recarregue a zona:

```bash
named-checkzone fatectech.com.br /etc/bind/domains/fatectech/db.fatectech.com.br
rndc reload fatectech.com.br
```

Depois, repita as consultas SOA da etapa 15. A VM2 deve receber o novo serial automaticamente.

---

# Parte 6 — Solução de problemas

## 18. O serviço não inicia

```bash
named-checkconf
systemctl status named --no-pager
journalctl -u named -n 50 --no-pager
```

Confira pontos e vírgulas, chaves, aspas, o caminho do arquivo e os pontos finais dos nomes completos.

## 19. A VM2 não recebe a zona

- Confirme a comunicação entre `192.168.200.1` e `192.168.200.2`.
- Verifique `allow-transfer { 192.168.200.2; };` na VM1.
- Verifique `masters { 192.168.200.1; };` na VM2.
- Garanta que a porta **TCP 53** não esteja bloqueada.
- Confirme que o serial da VM1 foi incrementado.

Para solicitar novamente a transferência na VM2:

```bash
rndc retransfer fatectech.com.br
journalctl -u named -n 50 --no-pager
```

## 20. A consulta retorna SERVFAIL ou REFUSED

Execute a consulta com a seção de comentários visível:

```bash
dig @192.168.200.1 fatectech.com.br SOA
dig @192.168.200.2 fatectech.com.br SOA
```

Em `status`, procure por `NOERROR`. Se houver erro, valide novamente a configuração e consulte o log do servidor que respondeu.

---

# Parte 7 — Preparação da entrega

Organize **um único arquivo PDF** com o nome completo dos integrantes e capturas legíveis. Os registros devem ser criados apenas na VM1 e disponibilizados na VM2 pela transferência de zona.

## 21. Arquivos de configuração

Registre capturas dos seguintes itens:

- Arquivo `/etc/bind/domains/fatectech/db.fatectech.com.br` na VM1.
- Arquivo `/etc/bind/named.conf.local` na VM1.
- Arquivo `/etc/bind/named.conf.local` na VM2.

```bash
cat /etc/bind/domains/fatectech/db.fatectech.com.br
cat /etc/bind/named.conf.local
```

## 22. Validações e estado do serviço

Inclua as saídas de `named-checkconf`, `named-checkzone` e o estado ativo do BIND9 nas duas máquinas.

```bash
named-checkconf
named-checkzone fatectech.com.br /etc/bind/domains/fatectech/db.fatectech.com.br
systemctl status named --no-pager
```

## 23. Consultas e transferência

Inclua capturas legíveis que demonstrem:

- Consultas `A`, `MX`, `NS` e `CNAME` ao servidor primário.
- As mesmas consultas ao servidor secundário.
- O mesmo serial SOA nas duas máquinas.
- A transferência de zona e o arquivo recebido na VM2.

Antes de gerar o PDF, identifique em cada captura a máquina em que o comando foi executado.

