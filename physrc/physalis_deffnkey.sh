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
    echo -e "\e[1;32m2024 (c) Sam + hglee - Physalis Tools - Default Fn-Key - \e[1;35m[CTRL+C] to Cancel\e[0m"
    echo -e "---------------------------------------------------------------------------\n"
}

clear_all

sudo -v

H=fnlock_default;G=asus_wmi;L=/etc/modprobe.d/alsa-base.conf;E="\n** $G $H";F=" **\n"

if [ -f /sys/module/$G/parameters/$H ]; then
    I="INSTALLED"
    grep -q "$H=N" $L
    if [ $? -eq 0 ]; then
        echo -e "$E $I ALREADY$F"
        exit 0
    fi
    O="options $G ${H}=N"
    echo -e "#Toggle $H at boot (Y/N)\n$O\n" | sudo tee -a $L
    echo -e "\nWait ...\n"
    sudo update-initramfs -u -k all
    echo -e "$E $I NOW$F"
    exit 0
fi
echo -e "$E NOT FOUND$F"
exit 1
#
