# TECH NET VPN — MODERNIZAÇÃO VISUAL v1.2

Data: 21/10/2026 · Mesmos arquivos, mesma estrutura, todas as ações preservadas.

## 1. NOVA IDENTIDADE VISUAL

Foi criada a **TNUi** (`Modulos/tnui`, instalada em `/bin/tnui`), a biblioteca visual
padrão da marca TECH NET VPN usada por todas as telas do painel:

- **Logo da marca** em duas versões (ampla para PC, compacta para celular)
- **Quadros arredondados** com título embutido e separadores de seção
- **Cartões de indicadores** (dashboard) lado a lado
- **Chips de status reais**: ● verde = serviço ativo, ○ vermelho = parado
  (verificação por processo, não decorativo)
- **Botões/opções padronizados**: `[ 01 ]` com numeração alinhada e descrição
- **Mensagens de estado padronizadas**: ✔ sucesso (verde), ✖ erro (vermelho), ℹ informação
- **Paleta da marca**: azul elétrico + ciano sobre o terminal, com cinzas de apoio
- **Responsividade real**: tudo se adapta à largura do terminal (`tput cols`) —
  em telas estreitas (celular/Termux) o layout muda para coluna única, cartões
  em blocos e logo compacto, sem cortar linhas nem sobrepor conteúdo

## 2. TELAS MODERNIZADAS (lista completa)

| # | Tela | Arquivo | O que mudou |
|---|------|---------|-------------|
| 1 | Dashboard / Menu principal | Modulos/menu | Logo da marca, linha do servidor (IP/sistema/hora), 6 cartões de indicadores (Online, Usuários, A Vencer, RAM, CPU, Swap), itens em 3 seções (Gerenciamento de Usuários / Servidor e Conexões / Sistema e Recursos), atalhos (C)heckuser, (B)adVPN, (V)2Ray, prompt padronizado |
| 2 | Menu "Mais Opções" (21-33) | Modulos/menu | Mesmo padrão do dashboard; chips de status para Bot Telegram, Bot Teste, Block Torrent e Auto Execução |
| 3 | Menu BADVPN (submenu B) | Modulos/menub | Quadro BADVPN • UDP com 4 opções e status do túnel |
| 4 | BadVPN Pro (ativar/parar) | Modulos/badpro | Quadro próprio, chip de status, mensagens ✔/✖ padronizadas |
| 5 | BadVPN Gerenciador | Modulos/badvpn2 | Cabeçalho no padrão TNUi |
| 6 | BadVPN ARM | Modulos/badvpn3 | Cabeçalho no padrão TNUi |
| 7 | Relatório de Usuários | Modulos/infousers | Tabela alinhada (Usuário/Senha/Limite/Validade) com cores por estado (Venceu em vermelho, Nunca em amarelo); rodapé com a marca (antes o rodapé era impresso 1x POR USUÁRIO — corrigido) |
| 8 | Remover Painel | Modulos/delscript | Quadro de aviso com explicação do que será feito + prompt padronizado |
| 9 | Mensagens do menu principal | Modulos/menu | "Opção inválida" e "ENTER para retornar" agora usam as caixas ✖/ℹ padronizadas |
| 10 | Página pública do Monitor Online | Install/onlineapp | HTML moderno e responsivo: tema escuro com a paleta da marca, cartões (Conexões/Usuários/Porta), tabela com indicador verde por usuário, atualização automática a cada 5s, layout que se ajusta a celular/tablet/PC. Mantido o arquivo de texto simples (`/server/online`) para compatibilidade, e o menu/instalador apontam para `online.html` |

Mantidos com o visual original (funcionais, sem risco desnecessário): telas internas
dos testes de conexão (Modulos/conexao), módulos de terceiros (checkers, mtuning,
fr, utili, banner etc.) e fluxos de instalação do `script/64/Plus` / `script/arm64/Plus`
(exceto as correções v1.1). Nenhuma funcionalidade foi removida; todos os botões/opções
continuam ligados às mesmas ações.

## 3. TESTES EXECUTADOS (evidências reais)

| Teste | Resultado |
|-------|-----------|
| Sintaxe (bash -n) de todos os arquivos alterados | OK |
| Render do dashboard, menu2 e menub a **80 colunas** (PC) | Marca presente, maior linha = exatamente 80, **zero linhas quebradas** |
| Render das mesmas telas a **45 colunas** (celular/Termux) | Marca presente, maior linha = exatamente 45, **zero linhas quebradas**, layout muda sozinho para coluna única |
| Badvpn Pro (tela nova) | Quadro renderiza, status ●/○ correto, opção 0 volta ao menu |
| Remover Painel (tela nova) | Quadro e prompt renderizam; resposta "n" sai sem alterar nada |
| Relatório de Usuários (tabela nova) | Tabela renderiza com colunas alinhadas |
| **Ações continuam funcionando** (painel real via TTY) | Opção 18 → LIMITER ativo (processo real); opção 4 → ONLINEAPP ativo; B+1+1 → BADVPN ativo (processo badvpn-udpgw no ar) |
| Página pública HTML | online.html/index.html/online gerados pelo serviço real; apache servindo em `http://IP:8888/server/online.html` com título "TECH NET VPN — Usuários Online" (verificado com curl) |

## 4. INSTALAÇÃO / ATUALIZAÇÃO

Igual à v1.1 (Ubuntu 20.04 e 24.04):

```bash
unzip TECH-NET-VPN-v1.2-visual.zip
cd TECH-NET-VPN-v1.2-visual
bash ssh-plus
```

O instalador copia a nova biblioteca `tnui` junto com os módulos (`Install/list`
atualizado). Para reinstalação sem o servidor de licença, use o modo livre:

```bash
mkdir -p /etc/technetvpn && echo "LICENCA_MODO=livre" > /etc/technetvpn/licenca.conf
bash ssh-plus
```

## 5. COMPATIBILIDADE

- Ubuntu 20.04 e 24.04 (testado em Debian 12 do ambiente de validação; os módulos
  usam apenas bash, tput, sed, awk e printf — presentes em ambos)
- Terminais de 36 a 200+ colunas; UTF-8
- A página do monitor funciona em qualquer navegador (sem dependência de JavaScript)
