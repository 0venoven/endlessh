#!/bin/bash

# Install dependencies
install_dependencies() {
    # Run apt update and capture the output in a variable and log file
    update_output=$(sudo apt update 2>&1 | tee /tmp/install_log.txt)

    # Capture the exit status of apt update immediately
    update_status=$?

    # Check if there were any errors in the update output
    if [ "$update_output" =~ "Temporary failure resolving" ]; then
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
    apt install -y openssh-server build-essential libc6-dev git netstat >> /tmp/install_log.txt 2>&1

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

# Change port of real ssh to something preferably higher than port 1024
configure_ssh_and_firewall() {
    # Change SSH port in /etc/ssh/sshd_config to 2244
    sed -i 's/Port 22/Port 2244/' /etc/ssh/sshd_config

    # Allow firewall on port 2244
    ufw allow 2244/tcp

    # Restart SSH
    systemctl restart ssh
}

# Clone, configure, compile and enable endlessh service
install_endlessh() {
    git clone https://github.com/skeeto/endlessh
    mkdir ~/endlessh
    cd ~/endlessh
    make
    mv endlessh /usr/local/bin/
    cp util/endlessh.service /etc/systemd/system/
    systemctl enable endlessh
    systemctl daemon-reload
    systemctl start endlessh
}

# Main script
echo "Setting up Endlessh on Ubuntu..."

install_dependencies
# TODO: change ssh port first
install_endlessh
# TODO: maybe netstat and get verification that the endlessh and real ssh services are running