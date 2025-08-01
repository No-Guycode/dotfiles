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

echo -e "${PURPLE}🌾 Installing all essential apps and dotfiles...${NC}"

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

# Install essential packages first
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

# Install Wayland/Hyprland ecosystem tools (without Hyprland itself)
echo -e "${BLUE}Installing Wayland ecosystem and utilities...${NC}"
WAYLAND_PACKAGES=(
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

for package in "${WAYLAND_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo -e "${GREEN}$package is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $package...${NC}"
        sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
    fi
done

# Install media and gaming packages (no duplicates with Flatpak)
echo -e "${BLUE}Installing media and gaming packages...${NC}"
MEDIA_PACKAGES=(
    "ffmpeg"
    "wine"
    "winetricks"
    "lutris"
    "audacity"
)

for package in "${MEDIA_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo -e "${GREEN}$package is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $package...${NC}"
        sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
    fi
done

# Install Unity Hub (corrected installation process)
echo -e "${BLUE}Installing Unity Hub...${NC}"
if ! command -v unityhub &> /dev/null; then
    echo -e "${YELLOW}Adding Unity Hub signing key...${NC}"
    wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null
    
    echo -e "${YELLOW}Adding Unity Hub repository...${NC}"
    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
    
    echo -e "${YELLOW}Updating package cache and installing Unity Hub...${NC}"
    sudo apt update
    sudo apt-get install -y unityhub
    
    echo -e "${GREEN}✅ Unity Hub installed successfully${NC}"
else
    echo -e "${GREEN}Unity Hub is already installed${NC}"
fi

# Install pywal
echo -e "${BLUE}Installing pywal...${NC}"
if ! command -v wal &> /dev/null; then
    pipx install pywal || pip3 install --user pywal
    echo -e "${GREEN}✅ pywal installed successfully${NC}"
else
    echo -e "${GREEN}pywal is already installed${NC}"
fi

# Install Flatpak apps
echo -e "${BLUE}Setting up Flatpak and installing apps...${NC}"
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
    if flatpak list | grep -q "$app"; then
        echo -e "${GREEN}$app is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $app...${NC}"
        sudo flatpak install -y flathub "$app" || echo -e "${RED}Failed to install $app${NC}"
    fi
done

# Install Oh My Zsh and related tools
echo -e "${BLUE}Installing Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}✅ Oh My Zsh installed${NC}"
else
    echo -e "${GREEN}Oh My Zsh is already installed${NC}"
fi

# Install Powerlevel10k
echo -e "${BLUE}Installing Powerlevel10k...${NC}"
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    echo -e "${GREEN}✅ Powerlevel10k installed${NC}"
else
    echo -e "${GREEN}Powerlevel10k is already installed${NC}"
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
        echo -e "${GREEN}✅ $plugin_name installed${NC}"
    else
        echo -e "${GREEN}$plugin_name is already installed${NC}"
    fi
done

# Build and install eww
echo -e "${BLUE}Building eww from source...${NC}"
if ! command -v eww &> /dev/null; then
    # Install Rust if not present
    if ! command -v cargo &> /dev/null; then
        echo -e "${YELLOW}Installing Rust...${NC}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install eww dependencies
    sudo apt install -y libgtk-3-dev libgtk-layer-shell-dev
    
    # Clone and build eww
    cd /tmp
    if [ -d "eww" ]; then
        rm -rf eww
    fi
    git clone https://github.com/elkowar/eww.git
    cd eww
    cargo build --release --no-default-features --features x11
    sudo cp target/release/eww /usr/local/bin/
    cd "$DOTFILES_DIR"
    echo -e "${GREEN}✅ eww installed successfully${NC}"
else
    echo -e "${GREEN}eww is already installed${NC}"
fi

# Change default shell to zsh
echo -e "${BLUE}Setting zsh as default shell...${NC}"
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
    chsh -s $(which zsh)
    echo -e "${GREEN}✅ Default shell changed to zsh${NC}"
else
    echo -e "${GREEN}Zsh is already the default shell${NC}"
fi

echo -e "${PURPLE}📁 Now copying configurations and assets...${NC}"

# Copy .config contents
if [ -d "$DOTFILES_DIR/.config" ]; then
    echo -e "${BLUE}Copying .config directory contents...${NC}"
    mkdir -p "$HOME/.config"
    cp -r "$DOTFILES_DIR/.config"/* "$HOME/.config/" 2>/dev/null || true
    echo -e "${GREEN}✅ Configuration files copied${NC}"
fi

# Copy shell configs
echo -e "${BLUE}Copying shell configuration files...${NC}"
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    echo -e "${GREEN}✅ .zshrc copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    cp "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    echo -e "${GREEN}✅ .bashrc copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.profile" ]; then
    cp "$DOTFILES_DIR/.profile" "$HOME/.profile"
    echo -e "${GREEN}✅ .profile copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.xinitrc" ]; then
    cp "$DOTFILES_DIR/.xinitrc" "$HOME/.xinitrc"
    echo -e "${GREEN}✅ .xinitrc copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.Xresources" ]; then
    cp "$DOTFILES_DIR/.Xresources" "$HOME/.Xresources"
    echo -e "${GREEN}✅ .Xresources copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
    cp "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo -e "${GREEN}✅ .tmux.conf copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    cp "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    echo -e "${GREEN}✅ .gitconfig copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.aliases" ]; then
    cp "$DOTFILES_DIR/.aliases" "$HOME/.aliases"
    echo -e "${GREEN}✅ .aliases copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.vimrc" ]; then
    cp "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
    echo -e "${GREEN}✅ .vimrc copied${NC}"
fi

if [ -f "$DOTFILES_DIR/.p10k.zsh" ]; then
    cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    echo -e "${GREEN}✅ .p10k.zsh copied${NC}"
fi

# Copy scripts
if [ -d "$DOTFILES_DIR/scripts" ]; then
    echo -e "${BLUE}Copying scripts...${NC}"
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/scripts"/*; do
        if [ -f "$script" ]; then
            cp "$script" "$HOME/.local/bin/$(basename "$script")"
            chmod +x "$HOME/.local/bin/$(basename "$script")"
            echo -e "${GREEN}✅ $(basename "$script") copied and made executable${NC}"
        fi
    done
fi

# Copy wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    echo -e "${BLUE}Copying wallpapers...${NC}"
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -r "$DOTFILES_DIR/wallpapers"/* "$HOME/Pictures/wallpapers/" 2>/dev/null || true
    echo -e "${GREEN}✅ Wallpapers copied${NC}"
fi

# Copy fonts
if [ -d "$DOTFILES_DIR/fonts" ]; then
    echo -e "${BLUE}Copying fonts...${NC}"
    mkdir -p "$HOME/.local/share/fonts"
    cp -r "$DOTFILES_DIR/fonts"/* "$HOME/.local/share/fonts/" 2>/dev/null || true
    fc-cache -fv
    echo -e "${GREEN}✅ Fonts copied and cache updated${NC}"
fi

# Copy icons
if [ -d "$DOTFILES_DIR/icons" ]; then
    echo -e "${BLUE}Copying icons...${NC}"
    mkdir -p "$HOME/.local/share/icons"
    cp -r "$DOTFILES_DIR/icons"/* "$HOME/.local/share/icons/" 2>/dev/null || true
    echo -e "${GREEN}✅ Icons copied${NC}"
fi

# Copy themes
if [ -d "$DOTFILES_DIR/themes" ]; then
    echo -e "${BLUE}Copying themes...${NC}"
    mkdir -p "$HOME/.local/share/themes"
    cp -r "$DOTFILES_DIR/themes"/* "$HOME/.local/share/themes/" 2>/dev/null || true
    echo -e "${GREEN}✅ Themes copied${NC}"
fi

# Copy pywal cache
if [ -d "$DOTFILES_DIR/pywal" ]; then
    echo -e "${BLUE}Copying pywal cache...${NC}"
    mkdir -p "$HOME/.cache"
    cp -r "$DOTFILES_DIR/pywal/wal" "$HOME/.cache/" 2>/dev/null || true
    echo -e "${GREEN}✅ Pywal cache copied${NC}"
fi

# Set up environment variables
echo -e "${BLUE}Setting up environment variables...${NC}"
if ! grep -q "# Hyprland environment variables" "$HOME/.profile" 2>/dev/null; then
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
    echo -e "${GREEN}✅ Environment variables added to .profile${NC}"
else
    echo -e "${GREEN}Environment variables already configured${NC}"
fi



echo ""
echo -e "${GREEN}🎉 Full dotfiles installation complete!${NC}"
echo ""
echo -e "${YELLOW}📦 Programs installed:${NC}"
echo -e "  • ${BLUE}Gaming:${NC} Steam, Lutris, Wine (Bottles for Windows apps)"
echo -e "  • ${BLUE}Development:${NC} VS Code (Flatpak), Unity Hub, Git"
echo -e "  • ${BLUE}Media:${NC} VLC (Flatpak), OBS Studio (Flatpak), Krita (Flatpak), Audacity"
echo -e "  • ${BLUE}Communication:${NC} Discord, Telegram, Firefox"
echo -e "  • ${BLUE}Productivity:${NC} LibreOffice, Spotify"
echo -e "  • ${BLUE}Utilities:${NC} Flameshot, Thunar, File Manager"
echo -e "  • ${BLUE}Wayland Tools:${NC} Waybar, Wofi, Rofi, Dunst, Swaylock (Hyprland-ready)"
echo -e "  • ${BLUE}Terminal:${NC} Kitty with Zsh + Oh My Zsh + Powerlevel10k"
echo -e "  • ${BLUE}Theming:${NC} Pywal for automatic color generation"
echo -e "  • ${BLUE}Widgets:${NC} eww (built from source)"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "  1. ${YELLOW}Reboot${NC} or log out and back in"
echo -e "  2. ${YELLOW}Install Hyprland manually${NC} when ready: 'sudo apt install hyprland'"
echo -e "  3. Start Hyprland with ${YELLOW}'Hyprland'${NC} command"
echo -e "  4. Generate pywal theme: ${YELLOW}'wal -i ~/Pictures/wallpapers/yourwallpaper.jpg'${NC}"
echo ""
echo -e "${PURPLE}🌾 Enjoy your new rice! 🎉${NC}"
