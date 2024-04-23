#!/bin/bash

# Define cores padronizadas
COLOR_SUCCESS="\e[1;32m"
COLOR_ERROR="\e[1;31m"
COLOR_RESET="\e[0m"
COLOR_WARNING="\e[1;33m"
COLOR_INFO="\e[1;36m"

print_success() {
    echo -e "${COLOR_SUCCESS}- [OK]${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_ERROR}- [Erro]${COLOR_RESET}"
    exit 1
}

clear_all(){
    clear
    echo -e "${COLOR_SUCCESS}2024 (c) Sam Mahonri - Physalis Tools - Discord Installer - ${COLOR_WARNING}[CTRL+C] para Cancelar${COLOR_RESET}"
    echo -e "------------------------------------------------------------------------------\n"
}

adaptive_version_ref() {
    local version=$1
    version_breaker=""
    discord_formatted=""

    if [ "$version" = "stable" ]; then
        version_breaker=""
        discord_formatted=""
    else
        version_breaker="-canary"
        discord_formatted="Canary"
    fi
}

uninstall_discord() {
    local version=$1
    adaptive_version_ref "$version"


    # Parar e desativar o serviço do Discord
    echo -n "- Parando e desativando o serviço do Discord... "
    sudo systemctl stop discord$version_breaker.service >/dev/null 2>&1
    sudo systemctl disable discord$version_breaker.service >/dev/null 2>&1
    print_success

    # Remover arquivo de serviço do Discord
    echo -n "- Removendo arquivo de serviço do Discord... "
    sudo rm -f "/etc/systemd/system/discord$version_breaker.service" >/dev/null 2>&1
    print_success

    # Remover diretório de instalação do Discord
    echo -n "- Removendo diretório de instalação do Discord... "
    sudo rm -rf "/opt/Discord$discord_formatted"
    print_success

    # Remover o aplicativo dos menus
    echo -n "- Removendo o aplicativo dos menus... "
    sudo rm -f "/usr/share/applications/discord$version_breaker.desktop" >/dev/null 2>&1
    print_success

    echo -e "\n${COLOR_SUCCESS}O Discord foi completamente desinstalado!${COLOR_RESET}\n"
    exit 0
}

add_to_menus() {
    local version=$1
    adaptive_version_ref "$version"
    echo -n "- Adicionando o aplicativo ao menu... "
    cat << EOF | sudo tee "/usr/share/applications/discord$version_breaker.desktop" >/dev/null
[Desktop Entry]
Name=Discord $version
Comment=All-in-one voice and text chat for gamers
Exec=/opt/Discord$discord_formated/Discord$discord_formated
Icon=/opt/Discord$discord_formated/discord.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;Game;
EOF
    print_success
}

clear_all

# Verificar se o processo do Discord está em execução
if pgrep -f "/opt/Discord" >/dev/null; then
    echo -e "${COLOR_WARNING}- Discord está atualmente em execução. Por favor, feche o Discord antes de prosseguir com a (des)instalação.\n${COLOR_RESET}"
    exit 1
fi

sudo -v

# Perguntar ao usuário se deseja instalar ou desinstalar o Discord
echo -e "${COLOR_INFO}Você deseja instalar ou desinstalar o Discord?${COLOR_RESET}"
select action in "Instalar" "Desinstalar"; do
    case $action in
        Instalar)
            break;;
        Desinstalar)
            # Perguntar ao usuário qual versão desinstalar
            echo -e "${COLOR_INFO}Qual versão do Discord você deseja desinstalar?${COLOR_RESET}"
            select version in "Stable" "Canary"; do
                case $version in
                    Stable)
                        uninstall_discord "stable";;
                    Canary)
                        uninstall_discord "canary";;
                    *)
                        echo "${COLOR_ERROR}Opção inválida. Por favor, selecione 1 ou 2.${COLOR_RESET}";;
                esac
            done;;
        *)
            echo "${COLOR_ERROR}Opção inválida. Por favor, selecione 1 ou 2.${COLOR_RESET}";;
    esac
done

clear_all

echo -e "${COLOR_INFO}Este script busca a versão oficial mais recente do Discord via sua API e facilita a instalação da versão Estável ou Canary. Ele garante a instalação correta na maioria dos sistemas Linux.${COLOR_RESET}\n"

# Perguntar ao usuário se deseja continuar com a instalação
read -p "Você deseja continuar com a instalação removendo a versão atual (se houver)? (s/n): " continue_install
if [[ $continue_install != "s" ]]; then
    echo -e "${COLOR_WARNING}- Instalação abortada.${COLOR_RESET}"
    exit 1
fi

# Selecionar versão do Discord (Estável ou Canary)
read -p "Qual versão do Discord você deseja instalar? (stable/canary): " discord_version
if [[ "$discord_version" != "stable" && "$discord_version" != "canary" ]]; then
    echo -e "${COLOR_ERROR}- Versão do Discord inválida. Por favor, escolha 'stable' ou 'canary'.${COLOR_RESET}"
    exit 1
fi

adaptive_version_ref "$discord_version"

# Verificar qual gerenciador de pacotes a distribuição atual utiliza
if command -v dnf >/dev/null; then
    package_manager="dnf"
elif command -v apt >/dev/null; then
    package_manager="apt"
elif command -v pacman >/dev/null; then
    package_manager="pacman"
else
    echo -e "${COLOR_ERROR}- Gerenciador de pacotes não suportado. Por favor, instale as dependências manualmente.${COLOR_RESET}"
    exit 1
fi

# Instalar dependências
echo -n "- Instalando dependências... "
if [ "$package_manager" = "dnf" ]; then
    if sudo dnf install -y libatomic libcxx libdbusmenu-gtk2 libindicator libappindicator GConf2; then
        print_success
    else
        print_error
    fi
elif [ "$package_manager" = "apt" ]; then
    if apt-get -m --ignore-missing --fix-missing install libatomic1 libc++1 libdbusmenu-gtk4 libappindicator3-1 gconf2; then
        print_success
    else
        print_error
    fi
elif [ "$package_manager" = "pacman" ]; then
    if sudo pacman -Sy --noconfirm libatomic libc++ libdbusmenu-gtk2 libappindicator-gtk2 libappindicator-gtk3 gconf; then
        print_success
    else
        print_error
    fi
fi

# Remover diretório de instalação do Discord anterior, se existir
echo -n "- Removendo diretório de instalação do Discord anterior... "
if [ -d "/opt/Discord$discord_formated" ]; then
    sudo rm -rf "/opt/Discord$discord_formated"
    print_success
else
    echo -e "${COLOR_WARNING}[!] Nenhuma instalação anterior do Discord encontrada.${COLOR_RESET}"
fi

# Baixar a versão mais recente do Discord para Linux
echo -e "- Baixando a versão mais recente do Discord para Linux...\n"
if wget -O "/tmp/discord$version_breaker.tar.gz" "https://discord.com/api/download/$discord_version?platform=linux&format=tar.gz"; then
    print_success
else
    print_error
fi

# Extrair a versão mais recente do Discord para Linux
echo -n "- Extraindo a versão mais recente do Discord para Linux... "
if tar -xvf "/tmp/discord$version_breaker.tar.gz" -C "/tmp" >/dev/null; then
    print_success
else
    print_error
fi

# Mover a instalação do Discord para o diretório /opt
echo -n "- Movendo a instalação do Discord para /opt... "
if sudo mv "/tmp/Discord$discord_formated" "/opt/Discord$discord_formated"; then
    print_success
else
    print_error
fi

# Adicionar o aplicativo aos menus
add_to_menus "$discord_version"

# Criar o arquivo de serviço systemd para o Discord
echo -n "- Criando o arquivo de serviço systemd para o Discord... "
cat << EOF | sudo tee "/etc/systemd/system/discord$version_breaker.service" >/dev/null
[Unit]
Description=Discord $discord_formated
After=network.target

[Service]
Type=simple
ExecStart=/opt/Discord$discord_formated/Discord$discord_formated

[Install]
WantedBy=multi-user.target
EOF
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi
sudo systemctl daemon-reload
sudo systemctl enable discord$version_breaker.service

chmod +x /opt/Discord$discord_formated/Discord$discord_formated

echo -e "\n${COLOR_SUCCESS}Instalação e configuração do Discord ($discord_version) concluídas com sucesso!${COLOR_RESET}\n"
read -p "Deseja iniciar o Discord agora? (s/n): " start_discord
if [[ $start_discord == "s" ]]; then
    # Iniciar o Discord em um novo processo
    nohup /opt/Discord$discord_formated/Discord$discord_formated >/dev/null 2>&1 &
    echo -e "${COLOR_SUCCESS}Discord iniciado.${COLOR_RESET}"
fi
