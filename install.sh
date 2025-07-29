#!/bin/bash
# Dotfiles Installation Script for Hyprland on Linux Mint
# Installs all your essential apps and configs

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${PURPLE}🌾 Installing dotfiles and all essential apps...${NC}"

# Function to create symlinks
create_symlink() {
    local src="$1"
    local dst="$2"
    
    if [ -e "$dst" ]; then
        echo -e "${YELLOW}Backing up existing $dst to $dst.backup${NC}"
        mv "$dst" "$dst.backup"
    fi
    
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo -e "${GREEN}Linked $src -> $dst${NC}"
}

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
sudo apt update

# Install essential packages
echo -e "${BLUE}Installing essential packages...${NC}"
ESSENTIAL_PACKAGES=(
    "git"
    "curl"
    "wget"
    "build-essential"
    "cmake"
    "ninja-build"
    "pkg-config"
    "libwayland-dev"
    "libxkbcommon-dev"
    "libegl1-mesa-dev"
    "libgles2-mesa-dev"
    "libdrm-dev"
    "libxkbcommon-x11-dev"
    "libpixman-1-dev"
    "wayland-protocols"
    "python3"
    "python3-pip"
    "python3-venv"
    "pipx"
    "zsh"
    "kitty"
    "neofetch"
    "fastfetch"
    "btop"
    "cava"
    "cowsay"
    "fortune"
    "lolcat"
    "tree"
    "htop"
    "unzip"
    "zip"
    "flatpak"
    "snapd"
    "software-properties-common"
    "apt-transport-https"
    "ca-certificates"
    "gnupg"
    "lsb-release"
)

for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo -e "${GREEN}$package is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $package...${NC}"
        sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
    fi
done

# Install Hyprland and related tools
echo -e "${BLUE}Installing Hyprland ecosystem...${NC}"
HYPRLAND_PACKAGES=(
    "hyprland"
    "xdg-desktop-portal-hyprland"
    "waybar"
    "wofi"
    "rofi"
    "dunst"
    "mako"
    "swaylock"
    "swayidle"
    "wlogout"
    "grim"
    "slurp"
    "swappy"
    "cliphist"
    "wl-clipboard"
    "brightnessctl"
    "playerctl"
    "pavucontrol"
    "network-manager-gnome"
    "blueman"
    "thunar"
    "thunar-archive-plugin"
    "file-roller"
    "fonts-font-awesome"
    "fonts-jetbrains-mono"
    "fonts-noto-color-emoji"
    "papirus-icon-theme"
    "arc-theme"
    "materia-gtk-theme"
    "lxappearance"
    "qt5ct"
    "qt6ct"
)

for package in "${HYPRLAND_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo -e "${GREEN}$package is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $package...${NC}"
        sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
    fi
done

# Install media and gaming
echo -e "${BLUE}Installing media and gaming packages...${NC}"
MEDIA_PACKAGES=(
    "vlc"
    "obs-studio"
    "krita"
    "audacity"
    "ffmpeg"
    "wine"
    "winetricks"
    "lutris"
)

for package in "${MEDIA_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo -e "${GREEN}$package is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $package...${NC}"
        sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
    fi
done

# Install pywal
echo -e "${BLUE}Installing pywal...${NC}"
pipx install pywal || pip3 install --user pywal

# Install Oh My Zsh
echo -e "${BLUE}Installing Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k
echo -e "${BLUE}Installing Powerlevel10k...${NC}"
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

# Install zsh plugins
echo -e "${BLUE}Installing zsh plugins...${NC}"
ZSH_PLUGINS=(
    "https://github.com/zsh-users/zsh-autosuggestions.git"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-history-substring-search.git"
)

for plugin in "${ZSH_PLUGINS[@]}"; do
    plugin_name=$(basename "$plugin" .git)
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$plugin_name" ]; then
        git clone "$plugin" "$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    fi
done

# Change default shell to zsh
echo -e "${BLUE}Setting zsh as default shell...${NC}"
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s $(which zsh)
fi

# Install Flatpak apps
echo -e "${BLUE}Installing Flatpak apps...${NC}"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

FLATPAK_APPS=(
    "com.valvesoftware.Steam"
    "com.discord.Discord"
    "com.microsoft.VsCode"
    "com.usebottles.bottles"
    "org.flameshot.Flameshot"
    "org.mozilla.firefox"
    "org.libreoffice.LibreOffice"
    "com.spotify.Client"
    "org.telegram.desktop"
    "org.videolan.VLC"
    "com.obsproject.Studio"
    "org.krita.Krita"
)

for app in "${FLATPAK_APPS[@]}"; do
    echo -e "${YELLOW}Installing $app...${NC}"
    sudo flatpak install -y flathub "$app" || echo -e "${RED}Failed to install $app${NC}"
done

# Install Unity Hub (if not already installed)
echo -e "${BLUE}Installing Unity Hub...${NC}"
if ! command -v unityhub &> /dev/null; then
    wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" | sudo tee /etc/apt/sources.list.d/unityhub.list
    sudo apt update
    sudo apt install -y unityhub
fi

# Build and install eww
echo -e "${BLUE}Building eww from source...${NC}"
if ! command -v eww &> /dev/null; then
    # Install Rust if not present
    if ! command -v cargo &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install eww dependencies
    sudo apt install -y libgtk-3-dev libgtk-layer-shell-dev
    
    # Clone and build eww
    cd /tmp
    git clone https://github.com/elkowar/eww.git
    cd eww
    cargo build --release --no-default-features --features x11
    sudo cp target/release/eww /usr/local/bin/
    cd "$DOTFILES_DIR"
    echo -e "${GREEN}✅ eww installed successfully${NC}"
fi

# Create symlinks for configs
echo -e "${BLUE}Creating symlinks for configurations...${NC}"

# Entire .config directory
if [ -d "$DOTFILES_DIR/.config" ]; then
    create_symlink "$DOTFILES_DIR/.config" "$HOME/.config"
fi

# Shell configs
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi

if [ -f "$DOTFILES_DIR/.profile" ]; then
    create_symlink "$DOTFILES_DIR/.profile" "$HOME/.profile"
fi

if [ -f "$DOTFILES_DIR/.xinitrc" ]; then
    create_symlink "$DOTFILES_DIR/.xinitrc" "$HOME/.xinitrc"
fi

if [ -f "$DOTFILES_DIR/.Xresources" ]; then
    create_symlink "$DOTFILES_DIR/.Xresources" "$HOME/.Xresources"
fi

if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
    create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
fi

if [ -f "$DOTFILES_DIR/.aliases" ]; then
    create_symlink "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
fi

if [ -f "$DOTFILES_DIR/.vimrc" ]; then
    create_symlink "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
fi

if [ -f "$DOTFILES_DIR/.p10k.zsh" ]; then
    create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
fi

# Install scripts
if [ -d "$DOTFILES_DIR/scripts" ]; then
    echo -e "${BLUE}Installing scripts...${NC}"
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/scripts"/*; do
        if [ -f "$script" ]; then
            create_symlink "$script" "$HOME/.local/bin/$(basename "$script")"
            chmod +x "$HOME/.local/bin/$(basename "$script")"
        fi
    done
fi

# Copy wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    echo -e "${BLUE}Installing wallpapers...${NC}"
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -r "$DOTFILES_DIR/wallpapers"/* "$HOME/Pictures/wallpapers/" 2>/dev/null || true
fi

# Install fonts
if [ -d "$DOTFILES_DIR/fonts" ]; then
    echo -e "${BLUE}Installing fonts...${NC}"
    mkdir -p "$HOME/.local/share/fonts"
    cp -r "$DOTFILES_DIR/fonts"/* "$HOME/.local/share/fonts/" 2>/dev/null || true
    fc-cache -fv
fi

# Install themes
if [ -d "$DOTFILES_DIR/themes" ]; then
    echo -e "${BLUE}Installing themes...${NC}"
    mkdir -p "$HOME/.local/share/themes"
    cp -r "$DOTFILES_DIR/themes"/* "$HOME/.local/share/themes/" 2>/dev/null || true
fi

# Restore pywal cache
if [ -d "$DOTFILES_DIR/pywal" ]; then
    echo -e "${BLUE}Restoring pywal cache...${NC}"
    mkdir -p "$HOME/.cache"
    cp -r "$DOTFILES_DIR/pywal/wal" "$HOME/.cache/" 2>/dev/null || true
fi

# Set up environment variables
echo -e "${BLUE}Setting up environment variables...${NC}"
cat >> "$HOME/.profile" << 'EOL'

# Hyprland environment variables
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export MOZ_ENABLE_WAYLAND=1
export GDK_BACKEND=wayland
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Pywal
(cat ~/.cache/wal/sequences &)
EOL

# Create a welcome script
echo -e "${BLUE}Creating welcome script...${NC}"
cat > "$HOME/.local/bin/welcome" << 'EOL'
#!/bin/bash
echo "$(tput setaf 6)"
cowsay "Welcome to your rice setup!" | lolcat
echo "$(tput sgr0)"
neofetch
EOL
chmod +x "$HOME/.local/bin/welcome"

echo -e "${GREEN}✅ Full dotfiles installation complete!${NC}"
echo -e "${YELLOW}Installed apps:${NC}"
echo -e "  • Steam, Discord, VS Code, Unity Hub"
echo -e "  • OBS Studio, VLC, Krita, Bottles"
echo -e "  • Kitty, Zsh with Oh My Zsh + Powerlevel10k"
echo -e "  • Pywal for theming"
echo -e "  • eww (built from source)"
echo -e "  • Cowsay and other fun tools"
echo -e "${BLUE}Please reboot or log out and back in for all changes to take effect.${NC}"
echo -e "${PURPLE}Run 'welcome' to see your new setup! 🎉${NC}"
