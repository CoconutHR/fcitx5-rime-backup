#!/usr/bin/env bash
set -euo pipefail

# =============================================================
#  Fcitx5 Rime 配置一键迁移脚本
#  仓库: https://github.com/CoconutHR/fcitx5-rime-backup
#  用法:
#    bash <(curl -fsSL https://raw.githubusercontent.com/CoconutHR/fcitx5-rime-backup/main/setup.sh)
#    或
#    git clone https://github.com/CoconutHR/fcitx5-rime-backup.git
#    cd fcitx5-rime-backup && bash setup.sh
# =============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║     Fcitx5 Rime 配置一键迁移                  ║"
echo "║     CoconutHR/fcitx5-rime-backup              ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)
echo -e "${YELLOW}检测到系统: $DISTRO${NC}"

install_deps() {
    echo -e "\n${CYAN}[1/6] 安装软件包...${NC}"
    case "$DISTRO" in
        ubuntu|debian|pop|linuxmint|neon)
            sudo apt update
            sudo apt install -y fcitx5 fcitx5-rime fcitx5-material-color
            ;;
        fedora)
            sudo dnf install -y fcitx5 fcitx5-rime fcitx5-material-color
            ;;
        arch|manjaro)
            sudo pacman -S --noconfirm fcitx5 fcitx5-rime fcitx5-material-color
            ;;
        opensuse*)
            sudo zypper install -y fcitx5 fcitx5-rime fcitx5-material-color
            ;;
        *)
            echo -e "${RED}不支持的发行版: $DISTRO${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}  ✅ 软件包安装完成${NC}"
}

backup_existing() {
    echo -e "\n${CYAN}[2/6] 备份现有配置...${NC}"
    BACKUP_DIR="/tmp/fcitx5-backup-$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    [ -f ~/.config/fcitx5/profile ] && cp ~/.config/fcitx5/profile "$BACKUP_DIR/"
    [ -f ~/.config/fcitx5/conf/classicui.conf ] && cp ~/.config/fcitx5/conf/classicui.conf "$BACKUP_DIR/"
    [ -f ~/.local/share/fcitx5/rime/default.custom.yaml ] && cp ~/.local/share/fcitx5/rime/default.custom.yaml "$BACKUP_DIR/"
    [ -f ~/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml ] && cp ~/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml "$BACKUP_DIR/"
    [ -f ~/.local/share/fcitx5/rime/user.yaml ] && cp ~/.local/share/fcitx5/rime/user.yaml "$BACKUP_DIR/"
    [ -d ~/.local/share/fcitx5/themes/Dark-Material ] && cp -r ~/.local/share/fcitx5/themes/Dark-Material "$BACKUP_DIR/"
    echo -e "${GREEN}  ✅ 备份到: $BACKUP_DIR${NC}"
}

copy_configs() {
    echo -e "\n${CYAN}[3/6] 复制配置文件...${NC}"
    mkdir -p ~/.config/fcitx5/conf
    mkdir -p ~/.local/share/fcitx5/rime
    mkdir -p ~/.local/share/fcitx5/themes/Dark-Material

    cp -v "$REPO_DIR/config/fcitx5/profile" ~/.config/fcitx5/profile
    cp -v "$REPO_DIR/config/fcitx5/conf/classicui.conf" ~/.config/fcitx5/conf/classicui.conf
    cp -v "$REPO_DIR/rime/default.custom.yaml" ~/.local/share/fcitx5/rime/default.custom.yaml
    cp -v "$REPO_DIR/rime/luna_pinyin_simp.custom.yaml" ~/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml
    cp -v "$REPO_DIR/rime/user.yaml" ~/.local/share/fcitx5/rime/user.yaml
    cp -v "$REPO_DIR/themes/Dark-Material/"* ~/.local/share/fcitx5/themes/Dark-Material/
    cp -v "$REPO_DIR/env/xprofile" ~/.xprofile
    cp -v "$REPO_DIR/env/pam_environment" ~/.pam_environment
    chmod +x ~/.xprofile

    if ! grep -q "GTK_IM_MODULE=fcitx5" ~/.bashrc 2>/dev/null; then
        cat >> ~/.bashrc << 'BASHRC'

# Fcitx5 input method
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export SDL_IM_MODULE=fcitx5
BASHRC
        echo "  ✅ 已追加环境变量到 ~/.bashrc"
    fi
    echo -e "${GREEN}  ✅ 配置文件复制完成${NC}"
}

system_config() {
    echo -e "\n${CYAN}[4/6] 系统配置...${NC}"
    if command -v im-config &>/dev/null; then
        sudo im-config -n fcitx5
        echo -e "${GREEN}  ✅ im-config 已设为 fcitx5${NC}"
    fi
    if [ -f /etc/profile.d/pop-im-ibus.sh ]; then
        sudo mv /etc/profile.d/pop-im-ibus.sh /etc/profile.d/pop-im-ibus.sh.bak
        echo -e "${GREEN}  ✅ pop-im-ibus.sh 已禁用${NC}"
    fi
    echo -e "${GREEN}  ✅ 系统配置完成${NC}"
}

deploy_rime() {
    echo -e "\n${CYAN}[5/6] 部署 Rime...${NC}"
    rm -rf ~/.local/share/fcitx5/rime/build/*
    rm -f ~/.local/share/fcitx5/rime/default.yaml
    if command -v rime_deployer &>/dev/null; then
        rime_deployer --build \
            ~/.local/share/fcitx5/rime \
            /usr/share/rime-data \
            ~/.local/share/fcitx5/rime/build
        echo -e "${GREEN}  ✅ rime_deployer 部署成功${NC}"
    else
        echo -e "${YELLOW}  ⚠️ rime_deployer 不可用，触发 fcitx5 部署...${NC}"
        if command -v fcitx5-remote &>/dev/null; then
            fcitx5-remote -r
            sleep 3
            echo -e "${GREEN}  ✅ fcitx5-remote 已触发重新部署${NC}"
        fi
    fi
}

restart_fcitx5() {
    echo -e "\n${CYAN}[6/6] 重启 Fcitx5...${NC}"
    if command -v fcitx5-remote &>/dev/null; then
        fcitx5-remote -e 2>/dev/null || true
    else
        pkill fcitx5 2>/dev/null || true
    fi
    sleep 1
    fcitx5 -d --replace 2>/dev/null &
    sleep 2
    echo -e "${GREEN}  ✅ Fcitx5 已重启${NC}"
}

finish() {
    echo -e "\n${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              🎉 配置完成！                    ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  打开任意输入框，按 ${YELLOW}Shift${NC} 切换到中文输入"
    echo -e "  按 ${YELLOW}Ctrl + \`${NC}（Ctrl+波浪号）切换输入方案"
    echo -e "  按 ${YELLOW}Super + 空格${NC} 切换输入法分组"
    echo ""
    echo -e "  ${YELLOW}建议重新登录桌面环境，确保所有环境变量生效。${NC}"
}

main() {
    echo -e "${YELLOW}"
    echo "  将会执行以下操作："
    echo "    1. 安装 fcitx5 + fcitx5-rime + 主题包"
    echo "    2. 备份你现有的配置到 /tmp"
    echo "    3. 复制 Rime 配置（暗色主题、9候选词等）"
    echo "    4. 设置系统输入法为 fcitx5"
    echo "    5. 部署 Rime 方案"
    echo "    6. 重启 Fcitx5"
    echo -e "${NC}"
    read -rp "继续执行？(y/N) " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "已取消"
        exit 0
    fi
    install_deps
    backup_existing
    copy_configs
    system_config
    deploy_rime
    restart_fcitx5
    finish
}

main "$@"
