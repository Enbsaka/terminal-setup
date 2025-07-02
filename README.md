# 🖥️ Terminal Setup

> Dotfiles e configurações pessoais versionadas para agilizar o setup de desenvolvimento em qualquer máquina Fedora nova.

---

## 📖 Sobre o Projeto

Este repositório centraliza **todas as minhas configurações de ambiente**: **Zsh + Oh My Zsh + Dracula**, aliases personalizados, configs do Git, config SSH com múltiplas contas, lista de pacotes DNF/Flatpak instalados e scripts automatizados de instalação e backup.

O objetivo é **replicar o ambiente de desenvolvimento com 1 comando só** sempre que formato a máquina ou acesso um ambiente novo, sem precisar configurar tudo do zero manualmente.

---

## 🛠️ Stack Utilizada

| Componente | Descrição |
|-----------|-----------|
| 🐧 **S.O.** | Fedora Workstation |
| 🐚 **Shell** | [Zsh](https://www.zsh.org/) |
| ⚡ **Framework** | [Oh My Zsh](https://ohmyz.sh/) |
| 🧛 **Tema** | [Dracula](https://draculatheme.com/zsh) |
| 🔌 **Plugins** | `git` • `zsh-autosuggestions` • `zsh-syntax-highlighting` |
| 📦 **Pacotes** | DNF + Flatpak (Spotify, DBeaver, DbGate) |

---

## 📂 Estrutura do Repositório

```
terminal-setup/
├── dotfiles/                          # Arquivos de configuração (linkados via symlink)
│   ├── .zshrc                         # Config principal do Zsh (tema + plugins)
│   ├── .bashrc                        # Fallback bash
│   ├── .bash_profile                  # Profile de login bash
│   ├── .zprofile                      # Profile de login Zsh
│   ├── .gitconfig                     # User do Git (enzosaka) + branch padrão main
│   ├── .gitignore_global              # Gitignore global (ignora .trae/)
│   └── ssh_config                     # SSH com 2 hosts (github-pessoal + github-empresa)
├── custom/                            # Pasta custom do Oh My Zsh (aliases, plugins, funções)
│   ├── aliases.zsh                    # Aliases personalizados (git, navegação, ls)
│   ├── example.zsh                    # Template padrão Oh My Zsh
│   └── plugins/
│       └── example/
│           └── example.plugin.zsh     # Exemplo de plugin custom
├── packages/                          # Listas de pacotes instalados
│   ├── dnf.list                       # Pacotes DNF (gerar com backup.sh ou comando manual)
│   └── flatpak.list                   # Flatpaks (Spotify, DBeaver, DbGate)
├── scripts/                           # Automação
│   ├── install.sh                     # 🔥 Bootstrap completo (instala TUDO e cria symlinks)
│   └── backup.sh                      # Copia dotfiles + listas da home pro repositório
├── LICENSE
└── README.md
```

---

## ⚙️ Instalação Rápida (1 comando)

### Pré-requisitos
- Acesso sudo
- `git` e `curl` instalados

```bash
# 1. Clone o repositório
git clone git@github.com:Enbsaka/terminal-setup.git ~/terminal-setup

# 2. Rode o bootstrap completo (é ele que faz TUDO)
cd ~/terminal-setup
./scripts/install.sh

# 3. Aplique as configurações no shell atual
source ~/.zshrc
```

---

## 🧠 O que o `install.sh` faz automaticamente?

| Etapa | Descrição |
|-------|-----------|
| 1 | Instala pacotes base (`zsh git curl`) via dnf/apt/pacman |
| 2 | Define Zsh como shell padrão (`chsh`) |
| 3 | Instala Oh My Zsh |
| 4 | Clona plugins `zsh-autosuggestions` + `zsh-syntax-highlighting` |
| 5 | Instala tema Dracula |
| 6 | Faz backup dos arquivos existentes e cria **symlinks** de todos os dotfiles (`~/.zshrc`, `~/.gitconfig`, `~/.ssh/config`, etc) pro repositório |
| 7 | Linka a pasta `custom/` do repositório no Oh My Zsh |
| 8 | Instala Flatpaks da lista (Spotify, DBeaver, DbGate) |
| 9 | Instala pacotes DNF da lista (se tiver sido gerada previamente) |

---

## 🔄 Ciclo de vida: Atualizando configurações

Sempre que você mudar qualquer arquivo (`.zshrc`, aliases, gitconfig, instalar pacote novo, etc):

```bash
# Copia TUDO da sua home pro repositório + gera listas de DNF/Flatpak atualizadas
cd ~/terminal-setup
./scripts/backup.sh

# Commita e sobe pro GitHub
git add .
git commit -m "Atualiza dotfiles"
git push
```

Pra aplicar essas alterações em **outra máquina**:
```bash
cd ~/terminal-setup
git pull
source ~/.zshrc
```

---

## 📝 Gerando a lista de pacotes DNF

> ⚠️ Precisa de sudo (o `backup.sh` já tenta automaticamente, mas se precisar fazer na mão):

```bash
sudo dnf history userinstalled | awk 'NR>2 {print $1}' | grep -v "^$" | sort -u > ~/terminal-setup/packages/dnf.list
```

Depois, em máquina nova, pra instalar tudo de uma vez:
```bash
sudo dnf install -y $(cat ~/terminal-setup/packages/dnf.list)
```

---

## ✅ Resultado esperado

Depois do `install.sh`:

- ✅ Terminal com tema **Dracula**
- ✅ **Autosuggestions** (sugestão cinza de comando enquanto digita)
- ✅ **Syntax highlighting** (comandos coloridos)
- ✅ Git configurado com user **enzosaka** e branch padrão **main**
- ✅ SSH com 2 contas GitHub (pessoal + empresa) funcionando
- ✅ Aliases carregados: `ll`, `gs`, `gp`, `gl`, `..`, `zshrc`, etc
- ✅ Flatpaks básicos instalados (Spotify, DBeaver, DbGate)
- ✅ **Todo dotfile é symlink pro repo** — alterações em `~/.zshrc` refletem direto no git

---

## 📝 Licença

Este projeto está sob a licença definida no arquivo [LICENSE](LICENSE).
