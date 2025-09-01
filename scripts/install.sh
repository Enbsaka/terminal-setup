#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

print_step() {
    echo -e "\n\033[1;34m==>\033[0m \033[1m$1\033[0m"
}

print_ok() {
    echo -e "\033[1;32m[OK]\033[0m $1"
}

print_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# ==============================
# 1. Instala pacotes base
# ==============================
print_step "Instalando pacotes base (zsh, git, curl)..."
if command -v dnf &>/dev/null; then
    sudo dnf install -y zsh git curl
elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y zsh git curl
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm zsh git curl
else
    print_warn "Gerenciador de pacotes não detectado. Instale zsh, git e curl manualmente."
fi

# ==============================
# 2. Define Zsh como shell padrão
# ==============================
print_step "Definindo Zsh como shell padrão..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    print_ok "Zsh definido como padrão. Faça logout/login para aplicar."
else
    print_ok "Zsh já é o shell padrão."
fi

# ==============================
# 3. Instala Oh My Zsh
# ==============================
print_step "Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_ok "Oh My Zsh instalado."
else
    print_ok "Oh My Zsh já instalado."
fi

# ==============================
# 4. Instala plugins obrigatórios
# ==============================
print_step "Instalando plugins do Oh My Zsh..."

PLUGIN_AUTO="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
PLUGIN_HL="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if [ ! -d "$PLUGIN_AUTO" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_AUTO"
    print_ok "zsh-autosuggestions instalado."
else
    print_ok "zsh-autosuggestions já instalado."
fi

if [ ! -d "$PLUGIN_HL" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_HL"
    print_ok "zsh-syntax-highlighting instalado."
else
    print_ok "zsh-syntax-highlighting já instalado."
fi

# ==============================
# 5. Instala tema Dracula
# ==============================
print_step "Instalando tema Dracula..."
THEME_DIR="$ZSH_CUSTOM/themes"
mkdir -p "$THEME_DIR"

if [ ! -f "$THEME_DIR/dracula.zsh-theme" ]; then
    TMP_DIR=$(mktemp -d)
    git clone https://github.com/dracula/zsh.git "$TMP_DIR"
    ln -sf "$TMP_DIR/dracula.zsh-theme" "$THEME_DIR/dracula.zsh-theme"
    ln -sf "$TMP_DIR/lib" "$THEME_DIR/lib"
    print_ok "Tema Dracula instalado."
else
    print_ok "Tema Dracula já instalado."
fi

# ==============================
# 6. Cria backups + symlinks dos dotfiles
# ==============================
print_step "Criando symlinks dos dotfiles..."

BACKUP_SUFFIX=".backup.$(date +%Y%m%d%H%M%S)"

declare -A DOTFILES=(
    [".zshrc"]="$HOME/.zshrc"
    [".bashrc"]="$HOME/.bashrc"
    [".bash_profile"]="$HOME/.bash_profile"
    [".zprofile"]="$HOME/.zprofile"
    [".gitconfig"]="$HOME/.gitconfig"
    [".gitignore_global"]="$HOME/.gitignore_global"
)

for SRC_NAME in "${!DOTFILES[@]}"; do
    DEST="${DOTFILES[$SRC_NAME]}"
    SRC="$REPO_DIR/dotfiles/$SRC_NAME"

    if [ -f "$DEST" ] && [ ! -L "$DEST" ]; then
        mv "$DEST" "${DEST}${BACKUP_SUFFIX}"
        print_ok "Backup criado: ${DEST}${BACKUP_SUFFIX}"
    fi

    if [ ! -L "$DEST" ] || [ "$(readlink -f "$DEST")" != "$SRC" ]; then
        ln -sf "$SRC" "$DEST"
        print_ok "Symlink criado: $DEST -> $SRC"
    else
        print_ok "Symlink OK: $DEST"
    fi
done

# SSH config (separado por ser arquivo sem ponto)
SSH_DIR="$HOME/.ssh"
SRC_SSH="$REPO_DIR/dotfiles/ssh_config"
DEST_SSH="$SSH_DIR/config"
if [ -f "$SRC_SSH" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    if [ -f "$DEST_SSH" ] && [ ! -L "$DEST_SSH" ]; then
        mv "$DEST_SSH" "${DEST_SSH}${BACKUP_SUFFIX}"
        print_ok "Backup criado: ${DEST_SSH}${BACKUP_SUFFIX}"
    fi
    if [ ! -L "$DEST_SSH" ] || [ "$(readlink -f "$DEST_SSH")" != "$SRC_SSH" ]; then
        ln -sf "$SRC_SSH" "$DEST_SSH"
        chmod 600 "$DEST_SSH"
        print_ok "Symlink criado: $DEST_SSH (SSH config)"
    fi
fi

# ==============================
# 7. Symlink da pasta custom do Oh My Zsh
# ==============================
print_step "Linkando pasta custom do Oh My Zsh..."
CUSTOM_SRC="$REPO_DIR/custom"
if [ -d "$CUSTOM_SRC" ]; then
    if [ -d "$ZSH_CUSTOM" ] && [ ! -L "$ZSH_CUSTOM" ]; then
        mv "$ZSH_CUSTOM" "${ZSH_CUSTOM}${BACKUP_SUFFIX}"
        print_ok "Backup criado: ${ZSH_CUSTOM}${BACKUP_SUFFIX}"
    fi
    if [ ! -L "$ZSH_CUSTOM" ] || [ "$(readlink -f "$ZSH_CUSTOM")" != "$CUSTOM_SRC" ]; then
        ln -sf "$CUSTOM_SRC" "$ZSH_CUSTOM"
        print_ok "Symlink criado: $ZSH_CUSTOM -> $CUSTOM_SRC"
    else
        print_ok "Symlink custom OK."
    fi
fi

# ==============================
# 8. Instala flatpaks
# ==============================
FLATPAK_LIST="$REPO_DIR/packages/flatpak.list"
if command -v flatpak &>/dev/null && [ -s "$FLATPAK_LIST" ]; then
    print_step "Instalando Flatpaks..."
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        if ! flatpak list --app --columns=application | grep -q "^${app}$"; then
            flatpak install -y flathub "$app" || print_warn "Falhou: $app"
        else
            print_ok "Flatpak OK: $app"
        fi
    done < "$FLATPAK_LIST"
fi

# ==============================
# 9. Instala pacotes DNF (se existir lista preenchida)
# ==============================
DNF_LIST="$REPO_DIR/packages/dnf.list"
if command -v dnf &>/dev/null && [ -f "$DNF_LIST" ] && grep -qv "^#\|^$" "$DNF_LIST"; then
    print_step "Instalando pacotes DNF..."
    sudo dnf install -y $(grep -v "^#\|^$" "$DNF_LIST")
fi

# ==============================
# FIM
# ==============================
echo -e "\n\033[1;32m✔ Instalação concluída!\033[0m"
echo "Rode 'source ~/.zshrc' para aplicar agora."
echo "Se mudou o shell padrão: faça logout/login."
