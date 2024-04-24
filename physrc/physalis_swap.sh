#!/bin/bash

print_success() {
    echo -e "\e[1;32m[OK]\e[0m"
}

print_error() {
    echo -e "\e[1;31m[Error]\e[0m"
    exit 1
}

clear_all(){
    clear
    echo -e "\e[1;32m2024 (c) Sam Mahonri - Physalis Tools - SWAP Manager - \e[1;35m[CTRL+C] to Cancel\e[0m"
    echo -e "-------------------------------------------------------------------------\n"
}

clear_all

sudo -v

read -p $'\e[1;33m< Please input the size of SWAP memory you wish to allocate (e.g., 32G):\e[0m ' swapsize

if [[ "$swapsize" =~ ^([0-9]+)([KMG])$ ]]; then
    swapsize_value=${BASH_REMATCH[1]}
    swapsize_unit=${BASH_REMATCH[2]}

    case $swapsize_unit in
        K)
            swapsize_value=$(echo "$swapsize_value * 0.000001" | bc)
            ;;
        M)
            swapsize_value=$(echo "$swapsize_value * 0.001" | bc)
            ;;
    esac

    available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')

    if (( $(echo "$swapsize_value > $available_space" | bc -l) )); then

        echo -e "\e[1;31m* There is not enough disk space to allocate the requested SWAP memory.\e[0m"
        exit 1
    else
        clear_all
        echo -e "\e[1;32m* Sufficient disk space to allocate the requested SWAP memory.\e[0m"
    fi
else
    echo -e "\e[1;31m* Invalid SWAP memory size. The format should contain 'G' at the end of the integer.\e[0m"
    exit 1
fi

echo -e "\e[1;33mBEFORE CONTINUING: If there is not enough physical memory, the system may hang during SWAP memory configuration.\e[0m"
read -p $'\e[1;33m< Do you want to continue? [y/N]:\e[0m ' choice

case "$choice" in
  y|Y)
    clear_all
    ;;
  *)
    echo -e "\e[1;31mSWAP memory configuration canceled by the user.\e[0m"
    exit 1
    ;;
esac

echo -e "\e[1;32mStarting SWAP memory configuration...\e[0m\n"

sudo swapoff -a &> /dev/null
echo -n "- Disabling current SWAP space... "
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

sudo rm -f ~/swapfile &> /dev/null
echo -n "- Removing existing SWAP file, if any... "
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

if df -T . | awk 'NR==2 {print $2}' | grep -q '^btrfs$'; then
    echo -e "\e[1;33m- Current filesystem is BTRFS. Performing additional specific actions...\e[0m"

    echo -n -e "\e[1;33m+ Additional step 1 (truncate)...\e[0m"

    sudo truncate -s 0 ~/swapfile &> /dev/null
    if [ $? -eq 0 ]; then
        print_success
    else
        print_error
    fi

    echo -n -e "\e[1;33m+ Additional step 2 (chattr)...\e[0m"

    sudo chattr +C ~/swapfile &> /dev/null
    if [ $? -eq 0 ]; then
        print_success
    else
        print_error
    fi
else
    echo "[!] Current filesystem is not BTRFS, continuing..."
fi

echo -n "- Creating a new SWAP file with the desired size... "
sudo fallocate -l "$swapsize" ~/swapfile &> /dev/null
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

echo -n "- Changing file permissions... "
sudo chmod 0600 ~/swapfile &> /dev/null
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

echo -n "- Making the new file a SWAP space... "
sudo mkswap ~/swapfile &> /dev/null
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

echo -n "- Activating the new SWAP space... "
sudo swapon ~/swapfile &> /dev/null
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

echo -n "- Making the change permanent... "
echo '~/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab &> /dev/null
if [ $? -eq 0 ]; then
    print_success
else
    print_error
fi

echo -e "\n\e[1;32mSWAP memory configuration completed successfully!\e[0m\n"
