#!/bin/bash
clear_all(){
    clear
    echo -e "\e[1;32m2024 (c) Sam Mahonri - Physalis Tools - \e[1;35m[CTRL+C] to Cancel\e[0m"
    echo -e "----------------------------------------------------------\n"
}

exibir_menu() {
    echo -e "\e[1;33m# Choose Tool:\n\e[0m"
    echo "  1. SWAP Manager"
    echo "  2. Battery Limiter"
    echo "  3. Discord Installer"
    echo -e "\e[1;31m  0. Exit\n\e[0m"
}

executar_swap_manager() {
    chmod +x ./physrc/physalis_swap.sh
    ./physrc/physalis_swap.sh
}

executar_battery_limiter() {
    chmod +x ./physrc/physalis_batlimit.sh
    ./physrc/physalis_batlimit.sh
}

executar_discord_installer(){
    chmod +x ./physrc/physalis_dcinstall.sh
    ./physrc/physalis_dcinstall.sh
}

while true; do
    clear_all
    exibir_menu

    read -p $'\e[1;33m< Select option [0 - 3]:\e[0m' opcao

    case $opcao in
        1) executar_swap_manager ;;
        2) executar_battery_limiter ;;
        3) executar_discord_installer ;;
        0) echo "Exiting..."; exit ;;
        *) echo "Invalid option. Try again." ;;
    esac

    read -p $'\e[1;35mPress [Enter] to Continue...\e[0m'
done
