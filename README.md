# Physalis Tools
Physalis Tools is a collection of utilities designed for configuring Linux systems, addressing common system issues. While tested primarily on ASUS® laptops with Fedora and Debian, it is compatible with most devices running a Unix-like operating system and utilizing Bash.

# Using Physalis Tools Shell Script
### Tools

- The `Swap Manager - physalis_swap.sh` script is designed to facilitate the configuration of SWAP memory on a Linux system. SWAP memory, also known as virtual memory, provides additional memory space when the physical RAM is full, helping prevent system crashes due to memory exhaustion. This script also supports the BTRFS filesystem.

- The `Battery Limiter - physalis_batlimit.sh` script should be used to adjust the maximum battery charging level of a laptop. This can increase the battery's lifespan by reducing recharge cycles. This tool has been tested on an ASUS with BAT0 but should work correctly on any laptop that supports this function.

- The `Discord Installer - physalis_dcinstall.sh` script was created with the difficulty of installing Discord correctly on some Linux distributions in mind. Often, it relies on third-party repositories, but this tool downloads Discord directly from the official Discord API, both the Stable and Canary versions, and installs it correctly on any Linux system, whether Debian-based (such as Ubuntu, Linux Mint, Elementary OS, Pop OS!, etc.) or Arch Linux-based (such as Fedora, Manjaro, Arco Linux, etc.). This tool also offers the option to uninstall properly. Furthermore, the installation includes some fixes that are not performed when installed from third-party repositories, such as installing necessary dependencies and configuring systemd for the correct addition of Discord to the system startup. (May not install porperly in GNOME)
---

# How to use

## Step 1: Make the Script Executable

Open a terminal window and navigate to the directory where `physalis.sh` is located. Then, run the following command to make the script executable:

```bash
chmod +x physalis.sh
```
This command grants execute permissions to the owner of the file.
Todos os scripts subsequentes que serão chamados por meio deste será definido como executável antes da execução, então não precisa se preocupar em mudar a permissão de cada script.

## Step 2: Execute the Script

Once the script is executable, you can run it using the following command:

```bash
./physalis.sh
```
This command executes the script named `physalis.sh` located in the current directory (`./`).

