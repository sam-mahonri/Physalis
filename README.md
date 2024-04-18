# Physalis Tools
Physalis Tools is a set of tools intended for specific configurations for Linux systems as tools for correcting common system problems. Currently it only has one tool.

# Physalis Swap Manager from Physalis Tools - `physalis_swap.sh` Shell Script
The physalis_swap.sh script is designed to facilitate the configuration of SWAP memory on a Linux system. SWAP memory, also known as virtual memory, provides additional memory space when the physical RAM is full, helping prevent system crashes due to memory exhaustion. This script also supports the BTRFS filesystem.

To execute the `physalis_swap.sh` shell script, follow these steps:

## Step 1: Make the Script Executable

Open a terminal window and navigate to the directory where `physalis_swap.sh` is located. Then, run the following command to make the script executable:

```bash
chmod +x physalis_swap.sh
```
This command grants execute permissions to the owner of the file.

## Step 2: Execute the Script

Once the script is executable, you can run it using the following command:

```bash
./physalis_swap.sh
```
This command executes the script named `physalis_swap.sh` located in the current directory (`./`).

During execution, the script will display messages indicating the progress of the SWAP memory configuration process. Monitor the output to ensure everything is proceeding as expected.
Once the script has completed execution, it will display a message indicating whether the SWAP memory configuration was successful or if there were any errors.
