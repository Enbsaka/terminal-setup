#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_DIR/dotfiles"

print_step() {
    echo -e "\n\033[1;34m==>\033[0m \033[1m$1\033[0m"
}

print_ok() {
    echo -e "\033[1;32m[OK]\033[0m Copiado: $1"
}

mkdir -p "$DEST"

declare -A DOTFILES=(
    [".zshrc"]="$HOME/.zshrc"
    [".bashrc"]="$HOME/.bashrc"
    [".bash_profile"]="$HOME/.bash_profile"
    [".zprofile"]="$HOME/.zprofile"
    [".gitconfig"]="$HOME/.gitconfig"
    [".gitignore_global"]="$HOME/.gitignore_global"
)

print_step "Copiando dotfiles da home para o repo..."

for NAME in "${!DOTFILES[@]}"; do
    SRC="${DOTFILES[$NAME]}"
    if [ -f "$SRC" ]; then
        cp -f "$SRC" "$DEST/$NAME"
        print_ok "$NAME"
    else
        echo -e "\033[1;33m[WARN]\033[0m Arquivo não encontrado: $SRC"
    fi
done

# SSH config
if [ -f "$HOME/.ssh/config" ]; then
    cp -f "$HOME/.ssh/config" "$DEST/ssh_config"
    chmod 644 "$DEST/ssh_config"
    print_ok "ssh_config"
fi

# Listas de pacotes
print_step "Gerando listas de pacotes..."

if command -v flatpak &>/dev/null; then
    flatpak list --app --columns=application | tail -n +1 | grep -v "^$" > "$REPO_DIR/packages/flatpak.list"
    print_ok "packages/flatpak.list ($(wc -l < "$REPO_DIR/packages/flatpak.list") flatpaks)"
fi

if command -v dnf &>/dev/null; then
    if sudo -n true 2>/dev/null; then
        sudo dnf history userinstalled 2>/dev/null | awk 'NR>2 {print $1}' | grep -v "^$" | sort -u > "$REPO_DIR/packages/dnf.list"
        print_ok "packages/dnf.list ($(wc -l < "$REPO_DIR/packages/dnf.list") pacotes)"
    else
        echo -e "\033[1;33m[WARN]\033[0m Para gerar dnf.list precisa de sudo. Rode manualmente:"
        echo "  sudo dnf history userinstalled | awk 'NR>2 {print \$1}' | grep -v \"^\$\" | sort -u > $REPO_DIR/packages/dnf.list"
    fi
fi

echo -e "\n\033[1;32m✔ Backup concluído!\033[0m"
echo "Arquivos atualizados em: $DEST"
echo "Agora commite e push: cd $REPO_DIR && git add . && git commit -m 'Atualiza dotfiles' && git push"
