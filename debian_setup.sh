#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Log setup
LOGFILE="/var/log/setup_debian.log"
exec > >(tee -a "$LOGFILE") 2>&1
exec 2> >(tee -a "$LOGFILE" >&2)

# Variables
NEEDS_REBOOT=false

# Functions
log() {
    echo -e "\n$(date +"%Y-%m-%d %T") - $1"
}

check_prerequisites() {
    log "Checking prerequisites..."
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Exiting."
        exit 1
    fi

    if ! grep -q "Debian" /etc/os-release; then
        echo "This script is intended for Debian systems only. Exiting."
        exit 1
    fi

    if ! ping -c 1 google.com &>/dev/null; then
        echo "No internet connection detected. Exiting."
        exit 1
    fi
}

update_and_upgrade() {
    log "Updating and upgrading system packages..."
    apt update && apt upgrade -y
}

install_packages() {
    log "Installing essential packages..."
    apt install -y \
        curl wget git unzip tar build-essential \
        net-tools htop tmux zsh ufw fail2ban \
        docker.io docker-compose-plugin python3 python3-pip \
        neofetch fzf rsyslog \
        fonts-firacode software-properties-common \
        gnupg ca-certificates nano \
        iftop iptraf-ng bmon bat ripgrep ncdu glances
}

configure_ufw() {
    log "Configuring UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw enable
}

install_lsd() {
    log "Installing lsd..."
    local LSD_VERSION
    LSD_VERSION=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
    wget https://github.com/lsd-rs/lsd/releases/download/$LSD_VERSION/lsd_${LSD_VERSION#v}_amd64.deb
    dpkg -i lsd_${LSD_VERSION#v}_amd64.deb
    rm lsd_${LSD_VERSION#v}_amd64.deb
}

install_oh_my_zsh() {
    log "Installing Oh-My-Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    fi
}

configure_zsh() {
    log "Configuring Zsh..."
    local ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    # Install Powerlevel10k theme
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    fi

    # Install plugins
    mkdir -p $ZSH_CUSTOM/plugins
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    fi
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    fi

    # Pre-configure .zshrc
    cat <<EOF > ~/.zshrc
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh
EOF

    # Change default shell
    chsh -s "$(which zsh)"
    NEEDS_REBOOT=true
}

configure_nano() {
    log "Configuring Nano editor..."
    mkdir -p ~/.nano/syntax
    wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh
    echo "set smooth" >> ~/.nanorc
    echo "set linenumbers" >> ~/.nanorc
    echo "include ~/.nano/syntax/*" >> ~/.nanorc
}

secure_ssh() {
    log "Securing SSH configuration..."
    local SSH_CONFIG=/etc/ssh/sshd_config

    # Backup SSH configuration
    cp $SSH_CONFIG ${SSH_CONFIG}.bak

    # Update SSH settings
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' $SSH_CONFIG
    systemctl reload sshd
}

configure_docker() {
    log "Configuring Docker..."
    groupadd docker || true
    usermod -aG docker $USER
    newgrp docker
    systemctl enable docker
}

configure_timezone_locale() {
    log "Setting timezone to UTC and locale to en_US.UTF-8..."
    timedatectl set-timezone UTC
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8
}

run_health_checks() {
    log "Running post-install health checks..."
    ufw status
    docker --version
    systemctl status docker | grep "Active: active"
}

cleanup() {
    log "Cleaning up unnecessary files..."
    apt autoremove -y
    apt autoclean -y
}

final_message() {
    log "Setup complete!"
    if [ "$NEEDS_REBOOT" = true ]; then
        echo "A reboot is required to apply all changes. Reboot now? (y/n)"
        read -r REBOOT_CHOICE
        if [[ "$REBOOT_CHOICE" == "y" ]]; then
            reboot
        fi
    fi
}

# Main Script Execution
main() {
    check_prerequisites
    update_and_upgrade
    install_packages
    configure_ufw
    install_lsd
    install_oh_my_zsh
    configure_zsh
    configure_nano
    secure_ssh
    configure_docker
    configure_timezone_locale
    run_health_checks
    cleanup
    final_message
}

# Run the script
main