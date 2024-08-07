#!/bin/bash
# Run this script right after OS install as a preliminary step before applying automated configuration using Ansible pull.
#
# - detects OS: Debian or Arch Linux
# - detects PVE host and configures apt sources for PVE no-subscription repository
# - installs pre-requisites for Ansible


# Function to configure PVE no-subscription repository
configure_pve_repo() {
    echo "Configuring Proxmox VE no-subscription repository..."
    sudo tee /etc/apt/sources.list.d/pve-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
EOF

    # Disable the enterprise repository
    sudo mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.disabled

    # Disable the CEPH repository
    sudo mv /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.disabled
}

# Function to install prerequisites on Debian-based systems
install_debian() {
    echo "Detected Debian-based system."

    # Check if it's a Proxmox VE host
    if grep -q "Proxmox Virtual Environment" /etc/os-release; then
        echo "Detected Proxmox VE host."
        configure_pve_repo
    fi

    # Update package list
    echo "Updating package list..."
    sudo apt-get update

    # Install Git
    echo "Installing Git..."
    sudo apt-get install -y git

    # Add Ansible PPA and install Ansible
    echo "Adding Ansible PPA..."
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible

    echo "Installing Ansible..."
    sudo apt-get install -y ansible

    # Verify installations
    echo "Verifying installations..."
    echo -n "Git version: "
    git --version
    echo -n "Ansible version: "
    ansible --version
}

# Function to install prerequisites on Arch Linux systems
install_arch() {
    echo "Detected Arch Linux system."
    
    # Update package list and install prerequisites
    echo "Updating package list..."
    sudo pacman -Syu --noconfirm

    # Install Git and Ansible
    echo "Installing Git and Ansible..."
    sudo pacman -S --noconfirm git ansible

    # Verify installations
    echo "Verifying installations..."
    echo -n "Git version: "
    git --version
    echo -n "Ansible version: "
    ansible --version
}

# Detect the operating system
if [ -f /etc/debian_version ]; then
    install_debian
elif [ -f /etc/arch-release ]; then
    install_arch
else
    echo "Unsupported operating system."
    exit 1
fi

echo "Prerequisites for ansible-pull have been installed."
