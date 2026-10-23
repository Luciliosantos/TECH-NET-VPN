# TECH NET VPN — RELATÓRIO DE CORREÇÕES v1.1

Data: 20/10/2026 · Todas as correções foram executadas e testadas de verdade (evidências abaixo).

---

## 1. POR QUE A ATIVAÇÃO/INSTALAÇÃO FALHAVA (causas reais, confirmadas por teste)

1. **Repositório GitHub do painel OFFLINE (HTTP 404).** TODA a instalação dependia de `wget` no
   `raw.githubusercontent.com/Luciliosantos/TECH-NET-VPN/main` (instalador auxiliar, módulos,
   versão, bot, chaves). Testado: o repositório não responde. → **Corrigido:** o instalador agora
   usa o **projeto local** (o próprio ZIP extraído no VPS) como fonte primária; o repositório
   remoto virou fallback opcional (`PANEL_REPO`).
2. **Servidor de licença `191.252.218.217:8787` inacessível.** Nota honesta: da sandbox de testes
   não é possível afirmar que o servidor está morto (a saída de rede aqui só abre TLS/443; a
   conexão na 8787 foi recusada pelo ambiente). No seu VPS o resultado pode ser diferente. Em
   QUALQUER dos casos o instalador agora se comporta de forma honesta: se não conectar, ele
   oferece [R] tentar de novo, [C] continuar SEM licença (gravado como NÃO-VALIDADA, sem fingir
   validação) ou [X] abortar. Há também o `LICENCA_MODO=livre` (ver seção 4) para reinstalação
   própria sem depender do servidor.
3. **`Install/list` (o instalador auxiliar) baixava tudo do repositório morto** e o `Plus` abortava
   quando o download falhava. → agora copia do projeto local.
4. **`fun_bar` sem timeout:** o `wget` do IP externo aguardava até ~15 minutos travado quando o
   servidor não respondia (reproduzido na prática). → adicionados `-T 5 -t 1` e fallback para o IP local.

## 2. POR QUE A BOLINHA DO STATUS NUNCA FICAVA VERDE (e dizia "ATIVADO" à toa)

Causas encontradas e corrigidas:

1. **O `onlineapp` (Monitor Online) NÃO EXISTIA no projeto.** O menu iniciava
   `screen -dmS onlineapp onlineapp` e o executável nunca veio em lugar nenhum — o processo
   nunca nascia, o indicador ficava (OFF) para sempre, e o painel ainda imprimia
   "ONLINE APP ATIVO !". → **Criado o `Install/onlineapp`** (monitor real que gera
   `/var/www/html/server/online`) e a mensagem agora só aparece se o processo subir DE VERDADE.
2. **badvpn: link do Dropbox MORTO + flag errada.** O `badpro` baixava o binário de
   `https://www.dropbox.com/s/48b36clnxkkurlz/...` com `-o` (flag inexistente de download) —
   ou seja, o binário nunca chegava ao `/bin` e a mensagem "BADVPN ATIVADO COM SUCESSO" era
   impressa sem verificar nada. → o binário **já existia dentro do projeto**
   (`Install/badvpn-udpgw`); agora o `Install/list` o instala direto, e a ativação é verificada
   (processo + event loop) antes de anunciar sucesso. Se falhar, o painel diz FALHOU e mostra
   como rodar manualmente para ver o erro.
3. **Status por `ps x | grep` engessado.** As bolinhas do menu checavam strings em `ps x`.
   → substituídas por `pgrep -f` no processo real (limiter, onlineapp, badvpn-udpgw).
4. **O status do MONITOR ONLINE era calculado e NUNCA exibido.** Agora aparece no menu,
   ao lado da opção [04], junto com o do LIMITER [18].

## 3. LOGO DO ANTIGO DONO QUE "PISCA E SOME" E A IDENTIDADE NO LOGIN

1. Havia um **`clear` no meio do cabeçalho do menu**: o painel pintava o logo e o apagava em
   seguida (efeito pisca-e-some). → removido; o logo agora é o `figlet TECH NET VPN` (mesmo
   padrão do instalador) e permanece na tela.
2. **MOTD do login SSH exibia a marca do painel antigo** por ~1s antes do `.bashrc` limpar a
   tela. → o instalador agora faz backup do MOTD antigo (`/etc/technetvpn/backup-*`) e grava o
   MOTD/`issue.net` do TECH NET VPN.
3. Marcas internas `@scottssh`, `@KIRITO_SSH` substituídas por `@TECHNETVPN`
   (licença interna, `infousers`, `delscript`, `conexao`).
4. **Dependência de terceiro eliminada:** `chuser`, `userscheck` e `checkuser.py` eram baixados
   do repositório de outra pessoa (wellzin-blip) a cada instalação. Agora vêm DENTRO do projeto
   (`Install/`).

## 4. COMO INSTALAR / REINSTALAR (VPS Ubuntu 18.04+, root)

```bash
# 1. extraia o ZIP no VPS e entre na pasta
unzip TECH-NET-VPN-v1.1-corrigido.zip
cd TECH-NET-VPN-v1.1-corrigido

# 2. execute o bootstrap (detecta arquitetura e roda o instalador LOCAL)
bash ssh-plus
```

- Se o servidor de licença estiver no ar, digite sua licença normalmente.
- Se estiver fora do ar (ou você não quiser usá-lo), escolha **C** no aviso — o painel instala
  e grava `NAO-VALIDADA-SERVIDOR-OFFLINE` (nada de validação forjada).
- Para reinstalação própria sem o aviso de licença:
  ```bash
  mkdir -p /etc/technetvpn && echo "LICENCA_MODO=livre" > /etc/technetvpn/licenca.conf
  bash ssh-plus
  ```
- Portas liberadas no firewall agora incluem **22 (SSH)** e **8888 (Monitor Online)** — antes o
  ufw podia bloquear o acesso do próprio dono e o app de monitoramento.

## 5. TESTES EXECUTADOS (evidências)

| # | Teste | Resultado |
|---|-------|-----------|
| T1 | Sintaxe de todos os scripts do projeto | OK (após reparar o `menub`, que vinha com erro de sintaxe até no repositório de origem — a opção B do menu nem abria) |
| T2 | `Install/list` real, fonte local | 22 arquivos instalados em `/bin` e `/etc/SSHPlus`; crontab (`@daily verifatt`, autostart); entradas de túnel no `/etc/hosts`; licença interna `by: @TECHNETVPN` |
| T3 | Serviços reais via `screen` (limiter, onlineapp, badvpn) | Os 3 processos ficaram no ar simultaneamente; expressões de status do menu retornaram **(ON◉)** nos três |
| T3a | badvpn-udpgw | Binário executável; log próprio: `initializing... entering event loop` (o event loop só inicia após o bind na 7300 ter sucesso) |
| T3b | Monitor Online de ponta a ponta | `onlineapp` gera `/var/www/html/server/online`; apache servindo em `http://IP:8888/server/online` (resposta HTTP verificada com curl) |
| T4.1 | Licença com servidor respondendo | "LICENÇA VALIDADA COM SUCESSO!" + licença gravada em `/etc/technetvpn/licenca` |
| T4.2 | Servidor offline + opção C | Mensagem honesta exibida + registro `NAO-VALIDADA-SERVIDOR-OFFLINE` |
| T4.3 | `LICENCA_MODO=livre` | Pula a validação sem simular sucesso |
| T5 | `verifatt` (cron diário) | Detecta diferença entre a versão instalada e a do projeto e grava aviso — antes fazia `wget` num domínio morto (`ssh-plus.tk`) todos os dias |

Limitações do ambiente de teste (sandbox, não defeitos do painel): processos em segundo plano
são encerrados entre chamadas de teste; o `/proc/net/udp` é virtualizado (netstat/ss não listam
soquetes aqui, por isso o bind da 7300 foi provado pelo log do próprio udpgw); o `screen` exige
um terminal real (comprovado com `script(1)`).

## 6. OUTROS DEFEITOS CORRIGIDOS ENCONTRADOS NA REVISÃO

- `menub` (menu BADVPN) vinha quebrado **desde o repositório de origem** (sem cabeçalho de
  função, com `}` solto) — a opção B do menu principal nem abria.
- `python-pip`/`python`/`netstat` na lista de pacotes: nomes inexistentes no Ubuntu 20.04+
  (o apt falhava no meio da instalação). Corrigido para `python3-pip`/`net-tools`.
- `.bashrc` duplicava o banner a cada reinstalação; agora é reescrito por marcadores.
- O instalador apagava o histórico do root (`~/.bash_history`) — histórico preservado.
- `mv` múltiplo que falhava inteiro (arquivo `cabecalho` não existe) — agora move um a um.
- `sed 3i` no `/etc/hosts` não inseria nada quando o arquivo tem menos de 3 linhas — corrigido.
- O `fun_bar` chegava a **apagar o `/bin/menu`** se faltasse `/usr/lib/sshplus` (mantido o
  requisito, agora garantido pelo instalador com o conteúdo correto).

## 7. O QUE PERMANECE DEPENDENDO DE TERCEIROS (documentado, sem engano)

- **Servidor de licença próprio:** o mecanismo de validação está no painel e funciona (T4.1);
  o servidor em `191.252.218.217:8787` precisa estar no ar OU você usa a opção C / modo livre.
- **Checkers/badpro1 ("abrir todas as portas"):** usam o repositório público ScottBrabo/PR0,
  que está no ar. Mantidos como estão.
- **hosts de túnel WhatsApp/Vivo:** entradas do `/etc/hosts` originais preservadas (têm que
  refletir o seu esquema de túnel; nada foi inventado aqui).

Arquivos originais modificados estão com backup em `backups/arquivos-modificados/` (no
workspace de entrega, fora do ZIP do projeto).
