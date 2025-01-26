# Setup Debian Server Script

This script automates the setup of a Debian-based server by installing essential packages, configuring security settings, and optimizing the system for productivity and performance.

## Features

### 1. System Update and Upgrade
- Updates the package list and upgrades existing packages.

### 2. Package Installation
Installs the following essential tools and utilities:
- **System Utilities**: `curl`, `wget`, `git`, `tmux`, `htop`, `neofetch`
- **Productivity Tools**: `nano` (with syntax highlighting), `fzf`, `bat`, `ripgrep`, `lsd`
- **Network Tools**: `net-tools`, `iftop`, `iptraf-ng`, `bmon`
- **Docker**: `docker.io`, `docker-compose-plugin`
- **Monitoring Tools**: `glances`, `ncdu`
- **Fonts**: `fonts-firacode`

### 3. UFW Firewall Configuration
- Sets up the UFW firewall with the following rules:
  - Deny all incoming traffic by default.
  - Allow outgoing traffic.
  - Allow traffic on ports `22` (SSH), `80` (HTTP), and `443` (HTTPS).

### 4. LSD Installation
- Installs the latest version of `lsd` (a modern alternative to `ls`).

### 5. Zsh Shell Configuration
- Installs and configures **Oh-My-Zsh** with:
  - **Powerlevel10k** theme.
  - Plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- Configures `.zshrc` with preloaded settings for productivity.

### 6. Nano Configuration
- Adds syntax highlighting and smooth scrolling for Nano.
- Configures `.nanorc` with helpful settings.

### 7. SSH Security Hardening
- Disables root login over SSH.
- Ensures password authentication is enabled.
- Reloads SSH service to apply changes.

### 8. Docker Configuration
- Installs Docker and its Compose plugin.
- Configures the current user for Docker group access.
- Enables Docker to start on boot.

### 9. Locale and Timezone Configuration
- Sets the timezone to UTC.
- Configures the locale to `en_US.UTF-8`.

### 10. Health Checks and Cleanup
- Verifies installations (e.g., UFW rules, Docker status).
- Cleans up unused packages and temporary files.

### 11. Reboot Management
- Notifies the user if a reboot is required and prompts for immediate reboot.

---

## Usage

### Step 1: Clone or Download the Script
```bash
wget https://your-repo-link/setup_debian.sh
```

### Step 2: Make the Script Executable
```bash
chmod +x setup_debian.sh
```

### Step 3: Run the Script
```bash
sudo ./setup_debian.sh
```

---

## Log File
All output from the script is logged to `/var/log/setup_debian.log`. If something goes wrong, you can review this log for debugging purposes.

---

## Requirements
- Debian-based system (Debian 10/11 or derivatives like Ubuntu).
- Root privileges.
- Active internet connection.

---

## Customization
The script is modular, making it easy to:
- Add or remove packages.
- Adjust configurations (e.g., change UFW rules or SSH settings).

To modify, open the script in a text editor:
```bash
nano setup_debian.sh
```

---

## License
This project is open-source and available under the MIT License.

---

## Contributions
Feel free to open issues or submit pull requests to enhance the script. Feedback and suggestions are always welcome!

---

## Acknowledgments
Thanks to:
- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [LSD](https://github.com/lsd-rs/lsd)
- [Nanorc](https://github.com/scopatz/nanorc)

---

<div align="center">
  Made with ❤️ by Stephen Jacobs
</div>

