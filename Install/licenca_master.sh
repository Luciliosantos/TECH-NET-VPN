#!/bin/bash
# TECH NET VPN - LICENCA MASTER
# Senha original, sem hash e sem vinculacao de VPS.

set -euo pipefail

DIR="/etc/technetvpn"
ATIVACAO="$DIR/master.activated"
SENHA_MASTER="Technet1999"

mkdir -p "$DIR"
chmod 700 "$DIR"

if [[ -s "$ATIVACAO" ]] &&
   grep -qx 'TECHNETVPN-MASTER-ACTIVATED-V1' "$ATIVACAO"; then
    echo "MASTER ja ativada nesta VPS."
    exit 0
fi

echo "=================================="
echo "       TECH NET VPN MASTER"
echo "=================================="

for tentativa in 1 2 3; do
    read -r -s -p "Digite a senha MASTER: " SENHA
    echo

    if [[ "$SENHA" == "$SENHA_MASTER" ]]; then
        printf '%s\n' 'TECHNETVPN-MASTER-ACTIVATED-V1' > "$ATIVACAO"
        chmod 600 "$ATIVACAO"

        echo "MASTER ativada com sucesso!"
        exit 0
    fi

    echo "Senha incorreta."
done

echo "Acesso MASTER negado."
exit 1
