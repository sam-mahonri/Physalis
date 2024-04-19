
#!/bin/bash

# Function to display success message
print_success() {
    echo -e "\e[1;32m[OK]\e[0m"
}

# Function to display error message and exit
print_error() {
    echo -e "\e[1;31m[Error]\e[0m"
    exit 1
}

# Clears the screen and displays title
clear_all(){
    clear
    echo -e "\e[1;32m2024 (c) Sam Mahonri - Physalis Tools - Battery Limiter - \e[1;35m[CTRL+C] to Cancel\e[0m"
    echo -e "----------------------------------------------------------------------------\n"
}

clear_all

# Requests sudo password
sudo -v

read -p $'\e[1;33m< Please enter the maximum battery charge percentage (e.g., 60):\e[0m ' maxbat

if [[ "$maxbat" =~ ^([0-9]) ]]; then
    if echo "$maxbat" | grep -E -q '^[0-9]+$'; then
        if [ "$maxbat" -gt 100 ] || [ "$maxbat" -le 0 ]; then
            echo -e "\e[1;31m* Please enter a valid maximum limit between 1-100 "
        else
            echo -n "- Limiting maximum battery capacity to $maxbat% ..."
            echo "$maxbat" | sudo tee /sys/class/power_supply/BAT?/charge_control_end_threshold > /dev/null
            if [ $? -eq 0 ]; then
                print_success
            else
                print_error
            fi

            cd /tmp

            echo -n "- Creating service for persistence... "
            echo "[Unit]
                  Description=To set battery charge threshold
                  After=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

                  [Service]
                  Type=oneshot
                  ExecStart=/bin/bash -c 'echo $max > /sys/class/power_supply/BAT?/charge_control_end_threshold'

                  [Install]
                  WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target" > battery-manager.service
            if [ $? -eq 0 ]; then
                print_success
            else
                print_error
            fi

            echo -n "- Copying service... "
            sudo cp battery-manager.service /etc/systemd/system/
            if [ $? -eq 0 ]; then
                print_success
            else
                print_error
            fi

            echo -n "- Enabling service... "
            sudo systemctl enable battery-manager.service
            if [ $? -eq 0 ]; then
                print_success
            else
                print_error
            fi

            echo -e "\n\e[1;32mBattery limit applied successfully!\e[0m\n"

        fi
    else
        echo  -e "\e[1;31m* Please enter a numeric maximum value"
    fi
else
    echo  -e "\e[1;31m* Please enter the maximum limit and try again"
fi

