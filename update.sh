#!/bin/bash
# Update dotfiles from current system

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Updating dotfiles from current system..."

# Backup entire .config directory
echo "Updating .config directory..."
if [ -d "$HOME/.config" ]; then
    rm -rf "$DOTFILES_DIR/.config"
    cp -r "$HOME/.config" "$DOTFILES_DIR/"
    echo "✅ .config directory updated"
fi

# Update shell configs
FILES_TO_UPDATE=(
    "$HOME/.zshrc"
    "$HOME/.bashrc"
    "$HOME/.profile"
    "$HOME/.xinitrc"
    "$HOME/.Xresources"
    "$HOME/.tmux.conf"
    "$HOME/.gitconfig"
    "$HOME/.aliases"
    "$HOME/.vimrc"
    "$HOME/.p10k.zsh"
)

for file in "${FILES_TO_UPDATE[@]}"; do
    if [ -f "$file" ]; then
        echo "Updating $(basename "$file")..."
        cp "$file" "$DOTFILES_DIR/"
    fi
done

# Update pywal cache
if [ -d "$HOME/.cache/wal" ]; then
    echo "Updating pywal cache..."
    rm -rf "$DOTFILES_DIR/pywal/wal"
    mkdir -p "$DOTFILES_DIR/pywal"
    cp -r "$HOME/.cache/wal" "$DOTFILES_DIR/pywal/"
fi

# Update wallpapers
if [ -d "$HOME/Pictures/wallpapers" ]; then
    echo "Updating wallpapers..."
    rm -rf "$DOTFILES_DIR/wallpapers"
    cp -r "$HOME/Pictures/wallpapers" "$DOTFILES_DIR/"
fi

echo "✅ Dotfiles updated! Remember to commit and push changes."
echo "Git status:"
git status --short
