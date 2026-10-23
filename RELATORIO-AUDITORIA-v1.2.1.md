# RELATÓRIO DE AUDITORIA — TECH NET VPN v1.2.1 (22/10/2026)

Base: TECH-NET-VPN-v1.2-visual (141 arquivos). Backups dos originais em `backups-modificados/`.

## 1. DIAGNÓSTICO (causas reais comprovadas no código)

| # | Problema | Causa raiz comprovada | Arquivo |
|---|----------|----------------------|--------|
| 1 | Submenu "Ferramentas" (17) não abre | Arquivo TRUNCADO upstream: fragmento sem cabeçalho de função, `done`/`}` soltos e pedaço de `fun_conexao` colado no fim | Modulos/utili |
| 2 | Submenu V2Ray quebra ao abrir | `}` solto na última linha (resto de wrapper de licença removido) — erro de sintaxe herdado do repositório original (presente também na v1.0) | Modulos/v2raymanager |
| 3 | WebSocket/SOCKS/OpenVPN-socks não sobem | wsproxy.py, proxy.py e open.py eram **Python 2 puro** (`import thread`, `print` sem parênteses). Ubuntu moderno só tem Python 3 → os 3 serviços morriam no `screen` silenciosamente. Portados para Python 3 e testados de verdade | Modulos/wsproxy.py, proxy.py, open.py |
| 4 | Bolinha verde "mentirosa" | OPENSSH tinha status verde FIXO (sem checagem); a variável `sts4` era compartilhada por 3 serviços (Socks/WebSocket Sec/Proxy DT) — indicava estado errado | Modulos/conexao |
| 5 | "Atualizar script" estragava o painel | attscript baixava list/v2raymanager/botteste/ShellBot do repositório antigo (OFFLINE) e do Dropbox do antigo dono, SUBSCREVENDO arquivos corrigidos | Modulos/attscript |
| 6 | Instaladores dependiam do repo antigo | cert/key/stunnel e EasyRSA (SSL Tunnel/OpenVPN) e init do squid baixados do GitHub antigo (morto) | Modulos/conexao, Modulos/instsqd, Install/instsqd |
| 7 | Falha silenciosa no BOT revenda | botssh chamava a URL do ShellBot SEM wget (comando inexistente) + baixava do repo antigo | Modulos/botssh |
| 8 | fail2ban (anti-DDoS) nunca instalava | tar.gz em link Dropbox morto | Modulos/ddos |
| 9 | multi não abria | mesmo `}` solto do item 2 | Modulos/multi |
| 10 | badvpn.sh/badvpn3 baixavam binário do repo do antigo dono | binário equivalente já existe no projeto | badvpn/badvpn.sh, Modulos/badvpn3, Modulos/badpro1 |

## 2. CORREÇÕES APLICADAS

**Python 3 (testado de verdade):** wsproxy.py/proxy.py/open.py convertidos (2to3 + correção manual da fronteira bytes/str: recv decodifica cabeçalhos, respostas HTTP em bytes, `_thread`, indentação normalizada). TESTE REAL EXECUTADO: wsproxy.py subiu, handshake HTTP 101 "Switching Protocols" recebido e túnel repassou dados ao alvo na porta 22 (dublê). 12 invocações `python` → `python3` no conexao (incluindo linhas de /etc/autostart).

**Status REAL em todo o fluxo de conexão:** tnui ganhou `tn_wait` (amarelo ◐), `tn_svc` e `tn_svc_udp` (verificam PROCESSO via pgrep E PORTA escutando via ss; retornam 1=verde, 0=vermelho, 2=amarelo). Menu "MODO DE CONEXÃO" reescrito: 14 serviços com checagem real (OpenSSH+SQUID+DROPBEAR+OPENVPN+PROXY SOCKS+WEBSOCKET+WEBSOCKET SECURITY+PROXY DT+SSL TUNNEL+SSLH+CHISEL+SLOWDNS+V2RAY+TROJAN-GO). Submenu WEB SOCKS reescrito com status real. Convenção: ● verde = operacional, ○ vermelho = parado/falha, ◐ amarelo = processo existe mas porta não escuta.

**Padrão visual TNUi generalizado:** 54 barras de título antigas convertidas em 14 módulos (badpro, badvpn2/3, banner, blockt, blockuser, botteste x2, conexao [32], criarusuario, detalhes, inst-botteste, swapmemory, v2raymanager [6]) + menus refeitos: utili (completo, 11 ferramentas mapeadas para módulos reais), v2raymanager (marca do antigo dono removida), fun_conexao, fun_socks, checkers, attscript, multi. figlet|lolcat eliminado do fluxo.

**Local-first (anti-repositório-antigo):** attscript agora atualiza SOMENTE do projeto local (/etc/technetvpn/source_dir), mostrando versões e contando arquivos. Install/list passa a guardar assets no VPS em /etc/SSHPlus/inst/ (cert, key, stunnel, EasyRSA-3.0.1.tgz, squid3, sshd_config, botssh) — SSL Tunnel, OpenVPN, init do squid e BOT TESTE usam esses arquivos com erro honesto se faltarem. badpro1/badvpn3/badvpn.sh usam os binários LOCAIS. ddos instala fail2ban via apt. botssh/botteste x3 copiam do projeto local. README com instalação pelo ZIP local.

**Licença preservada (intocada):** API http://191.252.218.217:8787/api/licenca/validar, LICENCA_MODO, validar_licenca, verifatt e /usr/lib/licence idênticos em 64/arm64 (confirmado por grep). Não mexer.

**Dependências externas mantidas (explícitas):** x-ui (menu V), v2ray.sh (multi.netlify.app, instalação do V2Ray), docker/tls-shunt-proxy/Linux-NetSpeed (trojan-go), dns do SlowDNS (TH30R10N/PR0 — binário não existe no projeto), webmin (webmin.com), checkuser DTunnel/GL/AnyChk (agora com AVISO explícito antes de baixar), multi (instaladores externos com aviso), bashtop (TUI próprio, intocado), whatismyip.akamai.com (IP público).

## 3. BINÁRIOS NÃO EDITÁVEIS (limitação registrada)

`security`, `initcheck`, `chuser`, `userscheck`, `fr`, `blocksite`, `limit`, `mtuning`, `trafegototal`, `apache2menu`, `painelv2ray`, `multi2`, `wssecury.sh`, `initbot`, `tuning`, `tweaker`, `vnc_inst`, `WebSocket`, `proxydt`, `badvpn-udpgw`, `slowdns`, `botssh`(binário em Sistema/). Não foram modificados; validação em VPS: executar e conferir comportamento. `Sistema/open.py` é cópia legada Python 2 não usada pelo instalador (a ativa é Modulos/open.py).

## 4. TESTES EXECUTADOS (de verdade) × PENDENTES (VPS limpa)

EXECUTADOS no sandbox:
- `bash -n` em 99 scripts do projeto: 0 erros (após correções de utili/v2raymanager/multi).
- `python3 -m py_compile` nos 3 serviços: OK.
- WebSocket Python 3: bind + handshake 101 + túnel ao alvo na 22: PASS (com alvo dublê).
- Smoke render com stubs (ss/screen/netstat/menu/figlet/lolcat): menu, menub, utili, checkers, conexao renderizam sem "command not found" nem erro de sintaxe; status do conexao mostra ○ vermelho para serviços inexistentes (correto).
- tn_svc: processo sem porta = verde; inexistente = vermelho (verificado).
- grep final: zero referências ativas ao repositório antigo nos módulos de execução (só restam as citadas como dependência externa explícita).

PENDENTES (exigem VPS limpa/serviços externos — NÃO executados aqui):
- Instalação completa em Ubuntu 18/20/22/24 (apt, squid, stunnel4, openvpn+EasyRSA).
- Licença real do BotLicenças (191.252.218.217:8787) e o fluxo R/C/X.
- Subir cada serviço real (squid/dropbear/openvpn/stunnel/chisel/slowdns/v2ray/trojan-go) e conferir ●.
- x-ui, trojan-go, slowdns (download do binário dns), addons checkuser externos.
- Instalador arm64 em VPS ARM.

## 5. INSTALAÇÃO EM VPS REINSTALADA (ordem)

1) BotLicenças (se ainda não estiver no servidor de licenças): ele roda à parte, no host do dono (191.252.218.217:8787) — não é instalado na VPS do painel. Apenas gere a licença do cliente nele.
2) Painel: envie este ZIP à VPS → `unzip TECH-NET-VPN-v1.2.1.zip -d /root/TECH-NET-VPN` → `cd /root/TECH-NET-VPN/TECH-NET-VPN-v1.2-visual` → `chmod +x ssh-plus && ./ssh-plus` → informe a licença quando pedida.
3) Atualizações futuras: opção "Atualizar script" no menu usa o projeto local (não baixa mais do GitHub antigo).

## 6. REVISÃO r2 (23/10/2026) — instalador preservado + substituição do repositório GitHub

Pedido do dono: corrigir mecanismos que ainda podem buscar arquivos ANTIGOS do GitHub, SEM remover/refazer o instalador. Verificado arquivo por arquivo, NADA do instalador foi alterado na estrutura: `ssh-plus`, `script/install`, `script/64/Plus`, `script/arm64/Plus` continuam intactos (só comentários/documentação), todos com `PANEL_REPO` sobreponível por variável de ambiente.

O que foi mudado AGORA (só no `Install/list`, que é a etapa de cópia, não o instalador):

1. **Lista de módulos _mdls: 77 → 69.** Removidas as 8 entradas de módulos que NÃO EXISTEM no projeto corrigido (Autobackup, backup_mail.sh, badvpn, cabecalho, dns-netflix.sh, ban.sh, prissh, prnet.sh). Eram o único mecanismo capaz de baixar versões ANTIGAS de arquivos do repositório: se o repo antigo ainda as contivesse, o instalador as instalaria sem correção. Verificado por grep: nenhum menu do painel invoca esses 8 comandos (as referências a "badvpn" no menu/menub são checagens de processo `pgrep badvpn-udpgw`, e "cabecalho" é comentário). Hoje TODAS as 69 entradas existem no pacote: se o dono substituir o conteúdo do repositório por este pacote, o instalador só pode instalar arquivos corrigidos.
2. **Assets com fallback ao repositório.** cert/key/stunnel/EasyRSA-3.0.1.tgz/squid3/sshd_config/botssh agora são obtidos via `fun_get` (local primeiro, repositório depois). Antes eram copiados SÓ do diretório local: numa instalação 100% via GitHub (one-liner, sem ZIP na VPS), os assets ficariam ausentes e SSL Tunnel/OpenVPN/BOT TESTE falhariam depois. Agora os dois fluxos funcionam.
3. **Versão do painel: local → repositório → padrão.** `/bin/versao` agora cai no `PANEL_REPO/Modulos/versao` quando o ZIP local não está presente (antes: valor fixo "32"). `Modulos/versao` = 121 (mesma convenção numérica do upstream; verifatt compara localmente, nunca baixa do domínio morto ssh-plus.tk desde a v1.1).

Estado do repositório GitHub hoje (testado ao vivo): **todas as URLs retornam 404** (repositório privado, vazio ou apagado). Enquanto o dono não o substituir, o one-liner remoto falha com erro honesto (mensagem do ssh-plus orienta extrair o TAR.GZ); a instalação pelo TAR.GZ local funciona 100% sem rede.

### Como substituir os arquivos antigos do repositório pelos corrigidos

1. Extraia o TAR.GZ: `tar xzf TECH-NET-VPN-v1.2.1-instalador.tar.gz`
2. Suba para o branch `main` TODO o conteúdo da pasta `TECH-NET-VPN-v1.2-visual/` MANTENDO OS CAMINHOS (na raiz do repo: `ssh-plus`; pastas: `Modulos/`, `Install/`, `script/`, `Sistema/`, `badvpn/`, `docs/` se usar).
3. APAGUE do repositório os 8 módulos removidos da lista (Autobackup, backup_mail.sh, badvpn, cabecalho, dns-netflix.sh, ban.sh, prissh, prnet.sh em Modulos/) — se ficarem, não serão instalados, mas é limpeza recomendada.
4. Não apague: `Install/badvpn-udpgw`, `Install/EasyRSA-3.0.1.tgz`, `Install/slowdns`, binários de `Modulos/` (initcheck, chuser, fr, etc.) — o instalador precisa deles.
5. Teste após subir: `wget -qO- https://raw.githubusercontent.com/Luciliosantos/TECH-NET-VPN/main/Modulos/versao` deve responder `121`.

### Dependências externas legítimas mantidas (todas avisa­das em tela ou documentadas)

x-ui (menu V), v2ray.sh em multi.netlify.app (instala o core V2Ray), docker/tls-shunt-proxy/Linux-NetSpeed (trojan-go), binário `dns` do SlowDNS (TH30R10N/PR0 — não existe no projeto), webmin (webmin.com), checkuser DTunnel/GL/AnyChk (checkers, com aviso antes de baixar), utilitários do `multi` (sshplus.xyz/VPS-MANAGER/botfree/ssl.sh do Dropbox — ferramentas OPT-IN de terceiros, nunca tocam arquivos do painel), IP público (whatismyip.akamai.com, icanhazip.com), IP do bot (api64.ipify.org). `verifatt` é 100% local desde a v1.1.

### Verificações executadas nesta revisão

`bash -n` em ssh-plus, script/install, Plus 64/arm64, Install/list, multi, attscript: OK. Smoke render do menu com stubs: 0 erros. Teste ao vivo das URLs do repositório (curl): 404 (confirma que, até a substituição, o único fluxo funcional é o TAR.GZ local — comportamento desejado). Recontagem _mdls: 69/69 presentes no pacote.

## 7. VERIFICAÇÃO FINAL DO PACOTE (r3, 23/10/2026) — executada sobre o TAR.GZ baixado do Drive

Procedimento: o TAR.GZ publicado foi baixado de volta de forma anônima (MD5 7983ebf9 confere) e TODO o conteúdo verificado item a item:

1. **Estrutura**: raiz completa (ssh-plus, Modulos/, Install/, script/, Sistema/, badvpn/, README, relatórios, backups-modificados).
2. **_mdls 69/69**: cada módulo da lista do Install/list existe em Modulos/ no pacote. Nenhum arquivo da instalação depende de download.
3. **Assets locais confirmados (tamanho real)**: Install/cert (2.228 B), Install/key (3.243 B), Install/stunnel (114 B — é o .conf do stunnel, não binário), Install/EasyRSA-3.0.1.tgz (40.960 B, tgz válido), Install/squid3 (3.585 B, init.d), Install/sshd_config (550 B), Install/jq-linux64 (3.027.945 B), Sistema/botssh (3.680 B, script bash do BOT TESTE), Install/badvpn-udpgw (binário x86_64 usado por badpro1/badvpn3/badvpn.sh).
4. **Instalador intacto no pacote**: ssh-plus, script/install, script/64/Plus, script/arm64/Plus, Install/list.

### Arquivos OBRIGATÓRIOS para instalação local (todos no pacote)

Instalador: ssh-plus, script/install, script/{64,arm64}/Plus, Install/list, Install/versao. Módulos: os 69 de _mdls (inclui tnui, utili, checkers, conexao, wsproxy.py, proxy.py, open.py corrigidos). Assets: cert, key, stunnel, EasyRSA-3.0.1.tgz, squid3, sshd_config, badvpn-udpgw, slowdns, jq-linux64, Sistema/botssh. Com esses arquivos a instalação pelo TAR.GZ funciona SEM NENHUM download do repositório. Não exigidos para o painel em si: docs/RELATORIO-*.md, backups-modificados/ (histórico), README.

### Dependências EXTERNAS legítimas (NÃO vêm no pacote, comportam-se com aviso/erro honesto se offline)

x-ui (menu V), core V2Ray (multi.netlify), docker/tls-shunt-proxy/Linux-NetSpeed (trojan-go), binário dns do SlowDNS (TH30R10N/PR0), webmin (webmin.com), checkuser DTunnel/GL/AnyChk (checkers), utilitários do multi (sshplus.xyz, VPS-MANAGER, botfree, ssl.sh Dropbox — OPT-IN), IP público (whatismyip/icanhazip), apt (squid, stunnel4, dropbear, openvpn, fail2ban, python3 etc. instalados via apt pelo instalador).

### ⚠️ ACHADOS desta verificação (transparência)

1. **Install/cert está VENCIDO** (autoassinado, CN=sslpingudomain.tk, validade ago/2021→nov/2021 — herança do projeto original). O stunnel sobe normalmente (não valida o próprio cert) e clientes VPN que não verificam certificado conectam sem problema, como sempre fizeram com este mesmo cert desde o projeto original. Para um certificado limpo, regenere NA VPS após instalar (o painel passará a usar o novo):
   `openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -keyout /etc/stunnel/key.pem -out /etc/stunnel/cert.pem -subj "/CN=seudominio"` (e reinicie o stunnel). A substituição NÃO foi feita no pacote para não alterar um asset em uso sem pedido.
2. **Pasta órfã "BADVPN UDP/" removida do pacote** (continha um 3º binário badvpn-udpgw de md5 diferente, referenciado por NENHUM script; cópia preservada fora do pacote). Os binários canônicos continuam no pacote: Install/badvpn-udpgw (usado pelos módulos) e badvpn/badvpn-udpgw (addon).

### Plano de teste PÓS-PUBLICAÇÃO (executar após o dono subir o pacote ao GitHub)

1. `wget -qO- https://raw.githubusercontent.com/Luciliosantos/TECH-NET-VPN/main/Modulos/versao` → deve responder **121**.
2. `wget -qO- .../main/Modulos/tnui | head -3` → deve ser a TNUi corrigida.
3. `wget -qO- .../main/Modulos/wsproxy.py | grep _thread` → vazio (Python 3 puro) confirma módulo corrigido no ar.
4. One-liner em VPS de teste: `bash <(wget -qO- .../main/ssh-plus)` → deve concluir sem "AVISO instalacao" em /etc/technetvpn/install.log.
5. VALIDAÇÃO COMPLETA só é declarada após instalação em **VPS Ubuntu limpa** (18/20/22/24): licença real, cada serviço subindo com ●, webhook/one-liner e arm64. Até lá, este relatório certifica apenas: estrutura, integridade, sintaxe, Python 3 dos serviços e renders — todos testados de verdade no sandbox.
