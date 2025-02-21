#!/bin/bash
set -e  # Exit on error

# Set the primary user
USER_NAME="jebbailey"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Update package list and upgrade installed packages
apt update && apt upgrade -y

# Install necessary packages
apt install -y \
    curl \
    git \
    wget \
    nano \
    tmux \
    htop \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    docker.io \
    docker-compose \
    zsh \
    fonts-powerline \
    unzip

# Create user if it does not exist
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/zsh "$USER_NAME"
fi

# Install and set up Miniforge3 for the primary user
sudo -u "$USER_NAME" bash -c "curl -L -o Miniforge3.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh && \
    bash Miniforge3.sh -b -p /home/$USER_NAME/miniforge3 && \
    rm Miniforge3.sh"

export PATH="/home/$USER_NAME/miniforge3/bin:$PATH"

# Change default shell to zsh
chsh -s $(which zsh) "$USER_NAME"

# Install Oh My Zsh for shell customization
sudo -u "$USER_NAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

# Install useful plugins and themes for zsh
sudo -u "$USER_NAME" git clone https://github.com/zsh-users/zsh-autosuggestions /home/$USER_NAME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo -u "$USER_NAME" git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/$USER_NAME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Set up a fancy prompt with Git integration
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$USER_NAME/.oh-my-zsh/custom/themes/powerlevel10k
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/$USER_NAME/.zshrc

# Enable plugins
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /home/$USER_NAME/.zshrc

# Add directory switching without cd
echo 'setopt AUTO_CD' >> /home/$USER_NAME/.zshrc

# Add conda initialization to zshrc
echo 'export PATH="/home/$USER_NAME/miniforge3/bin:$PATH"' >> /home/$USER_NAME/.zshrc
echo 'eval "$(/home/$USER_NAME/miniforge3/bin/conda shell.zsh hook)"' >> /home/$USER_NAME/.zshrc

# Add Docker permissions for the primary user
usermod -aG docker "$USER_NAME"

# Enable and start Docker
tsystemctl enable --now docker

# Set up SSH keys (ensure SSH is installed and running)
#mkdir -p /home/$USER_NAME/.ssh
#cp /root/.ssh/authorized_keys /home/$USER_NAME/.ssh/authorized_keys || touch /home/$USER_NAME/.ssh/authorized_keys
#chown -R "$USER_NAME":"$USER_NAME" /home/$USER_NAME/.ssh
#chmod 700 /home/$USER_NAME/.ssh
#chmod 600 /home/$USER_NAME/.ssh/authorized_keys

# Placeholder for additional system setup hooks
echo "System setup complete. You may add additional setup steps here."

# Reboot to apply changes
echo "Rebooting in 10 seconds..."
sleep 10
reboot
