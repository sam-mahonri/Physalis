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
    echo -e "${COLOR_ERROR}- [Error]${COLOR_RESET}"
    exit 1
}

clear_all(){
    clear
    echo -e "${COLOR_SUCCESS}2024 (c) Sam Mahonri - Physalis Tools - Discord Installer - ${COLOR_WARNING}[CTRL+C] to Cancel${COLOR_RESET}"
    echo -e "------------------------------------------------------------------------------\n"
}

uninstall_discord() {
    local version=$1
    if [ "$version" = "stable" ]; then
        discord_formated=""
    else
        discord_formated="Canary"
    fi
    # Stop and disable Discord service
    echo -n "- Stopping and disabling Discord service... "
    sudo systemctl stop discord-$version.service >/dev/null 2>&1
    sudo systemctl disable discord-$version.service >/dev/null 2>&1
    print_success

    # Remove Discord service file
    echo -n "- Removing Discord service file... "
    sudo rm -f "/etc/systemd/system/discord-$version.service" >/dev/null 2>&1
    print_success

    # Remove Discord installation directory
    echo -n "- Removing Discord installation directory... "
    sudo rm -rf "/opt/Discord$discord_formated"
    print_success

    echo -e "\n${COLOR_SUCCESS}Discord ($version) has been completely uninstalled!${COLOR_RESET}\n"
    exit 0
}

clear_all

# Check if Discord process is running
if pgrep -f "/opt/Discord" >/dev/null; then
    echo -e "${COLOR_WARNING}- Discord is currently running. Please close Discord before proceeding with the (un)installation.\n${COLOR_RESET}"
    exit 1
fi

sudo -v

# Ask user whether to install or uninstall Discord
echo -e "${COLOR_INFO}Do you want to install or uninstall Discord?${COLOR_RESET}"
select action in "Install" "Uninstall"; do
    case $action in
        Install)
            break;;
        Uninstall)
            # Ask user which version to uninstall
            echo -e "${COLOR_INFO}Which version of Discord do you want to uninstall?${COLOR_RESET}"
            select version in "Stable" "Canary"; do
                case $version in
                    Stable)
                        uninstall_discord "stable";;
                    Canary)
                        uninstall_discord "canary";;
                    *)
                        echo "${COLOR_ERROR}Invalid option. Please select either 1 or 2.${COLOR_RESET}";;
                esac
            done;;
        *)
            echo "${COLOR_ERROR}Invalid option. Please select either 1 or 2.${COLOR_RESET}";;
    esac
done

clear_all

echo -e "${COLOR_INFO}This script fetches the latest official version of Discord via its API and facilitates the installation of either the Canary or Stable version. It ensures correct installation on most Linux systems.${COLOR_RESET}\n"

# Ask user if they want to continue
read -p "Do you want to continue with the installation by removing the current version (if any)? (y/n): " continue_install
if [[ $continue_install != "y" ]]; then
    echo -e "${COLOR_WARNING}- Installation aborted.${COLOR_RESET}"
    exit 1
fi

# Select Discord version (Stable or Canary)
read -p "Which version of Discord do you want to install? (stable/canary): " discord_version
if [[ "$discord_version" != "stable" && "$discord_version" != "canary" ]]; then
    echo -e "${COLOR_ERROR}- Invalid Discord version. Please choose 'stable' or 'canary'.${COLOR_RESET}"
    exit 1
fi

if [ "$discord_version" = "stable" ]; then
    discord_formated=""
else
    discord_formated="Canary"
fi

# Check which package manager the current distribution uses
if command -v dnf >/dev/null; then
    package_manager="dnf"
elif command -v apt >/dev/null; then
    package_manager="apt"
elif command -v pacman >/dev/null; then
    package_manager="pacman"
else
    echo -e "${COLOR_ERROR}- Unsupported package manager. Please install the dependencies manually.${COLOR_RESET}"
    exit 1
fi

# Install dependencies
echo -n "- Installing dependencies... "
if [ "$package_manager" = "dnf" ]; then
    if sudo dnf install -y libatomic libcxx libdbusmenu-gtk2 libindicator libappindicator GConf2; then
        print_success
    else
        print_error
    fi
elif [ "$package_manager" = "apt" ]; then
    if sudo apt install -y libatomic1 libc++1 libdbusmenu-gtk4 libindicator3-7 libappindicator3-1 gconf2; then
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

# Remove previous Discord installation directory if exists
echo -n "- Removing previous Discord installation directory... "
if [ -d "/opt/Discord$discord_formated" ]; then
    sudo rm -rf "/opt/Discord$discord_formated"
    print_success
else
    echo -e "${COLOR_WARNING}[!] No previous Discord installation found.${COLOR_RESET}"
fi

# Download the latest version of Discord for Linux
echo -e "- Downloading the latest version of Discord for Linux...\n"
if wget -O "/tmp/discord-$discord_version.tar.gz" "https://discord.com/api/download/$discord_version?platform=linux&format=tar.gz"; then
    print_success
else
    print_error
fi

# Extract the latest version of Discord for Linux
echo -n "- Extracting the latest version of Discord for Linux... "
if tar -xvf "/tmp/discord-$discord_version.tar.gz" -C "/tmp" >/dev/null; then
    print_success
else
    print_error
fi

# Move the Discord installation to the /opt directory
echo -n "- Moving the Discord installation to /opt... "
if sudo mv "/tmp/Discord$discord_formated" "/opt/Discord$discord_formated"; then
    print_success
else
    print_error
fi

# Create the systemd service file for Discord
echo -n "- Creating the systemd service file for Discord... "
cat << EOF | sudo tee "/etc/systemd/system/discord-$discord_version.service" >/dev/null
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

chmod +x /opt/Discord$discord_formated/Discord$discord_formated

echo -e "\n${COLOR_SUCCESS}Installation and configuration of Discord ($discord_version) completed successfully!${COLOR_RESET}\n"
