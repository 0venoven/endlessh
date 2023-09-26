#!/bin/bash

# Function to install dependencies
install_dependencies() {
    # Run apt update and capture the output in a variable and log file
    update_output=$(sudo apt update 2>&1 | tee /tmp/install_log.txt)

    # Capture the exit status of apt update immediately
    update_status=$?

    # Check if there were any errors in the update output
    if [[ "$update_output" =~ "Temporary failure resolving" ]]; then
        echo "Warning: Failed to update package index. Check your internet connection."
        echo "Proceeding with package installation using cached index..."
    fi

    # Check the exit status of apt update
    if [ $update_status -eq 0 ]; then
        echo "Package update completed successfully."
    else
        echo "Package update failed. Check /tmp/install_log.txt for details."
        exit 1
    fi

    # Redirect both stdout and stderr to a log file and execute apt install
    sudo apt install -y openssh-server build-essential libc6-dev >> /tmp/install_log.txt 2>&1

    # Capture the exit status of apt install immediately
    install_status=$?

    # Check the exit status of apt install
    if [ $install_status -eq 0 ]; then
        echo "Package installation completed successfully."
    else
        echo "Package installation failed. Check /tmp/install_log.txt for details."
        exit 1
    fi
}

# Main script
echo "Setting up Endlessh on Ubuntu..."

# Call the function
install_dependencies