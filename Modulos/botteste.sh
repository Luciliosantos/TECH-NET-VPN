#!/bin/bash
[[ -f /bin/tnui ]] && source /bin/tnui
[[ $(screen -list| grep -c 'bot_teste') == '0' ]] && {
    clear
        tn_box_top "ATIVACÃO BOT SSH TESTE"
    echo ""
    echo -ne "\n\033[1;32mINFORME O TOKEN\033[1;37m: "
    read token
    clear
    echo ""
    echo -e "\033[1;32mINICIANDO BOT TESTE \033[0m\n"
    cd $HOME/BOT
    rm -rf $HOME/BOT/botssh
    # CORRIGIDO: botssh vem do projeto local (antes: repositorio antigo)
    SRC=$(cat /etc/technetvpn/source_dir 2>/dev/null)
    if [[ -f /etc/SSHPlus/inst/botssh ]]; then
        cp -f /etc/SSHPlus/inst/botssh $HOME/BOT/botssh
    elif [[ -n "$SRC" && -f "$SRC/Sistema/botssh" ]]; then
        cp -f "$SRC/Sistema/botssh" $HOME/BOT/botssh
    else
        echo -e "\033[1;31mERRO: Sistema/botssh ausente no projeto local.\033[0m"
        sleep 3
        menu
    fi
    chmod +x botssh
    echo ""
    sleep 1
    screen -dmS bot_teste ./botssh $token > /dev/null 2>&1
    clear
    echo "BOT ATIVADO"
    menu
} || {
    screen -r -S "bot_teste" -X quit
    clear
    echo "BOT DESATIVADO"
    menu
}
