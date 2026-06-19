---
name: rime-setup
trigger:
  - "安装中文输入法"
  - "Rime 配置"
  - "fcitx5 输入法"
  - "rime 输入法"
  - "配置 Rime"
description: >
  一键部署 CoconutHR 的 Fcitx5 Rime 输入法配置
  （暗色主题 + 朙月拼音·简化字 + 9 候选词）

steps:
  - 克隆仓库 CoconutHR/fcitx5-rime-backup
  - 检测发行版并安装 fcitx5、fcitx5-rime、fcitx5-material-color
  - 备份用户现有的 Rime/Fcitx5 配置到 /tmp
  - 复制所有配置文件到对应路径
  - 配置系统环境变量（xprofile、pam_environment、bashrc）
  - 运行 rime_deployer 部署
  - 重启 fcitx5
  - 提示用户重新登录桌面环境
---

# Rime 输入法配置安装

此技能自动部署 CoconutHR 的 Fcitx5 Rime 输入法配置。

## 效果

- **深色主题** Dark-Material（黑底 + 灰字 + 蓝色高亮）
- **方案**：朙月拼音·简化字（luna_pinyin_simp）+ 地球拼音（terra_pinyin）
- **9 个候选词**，横向排列
- **简化字模式**默认开启

## 执行步骤

### 1. 克隆仓库

```bash
git clone https://github.com/CoconutHR/fcitx5-rime-backup.git /tmp/fcitx5-rime-backup
cd /tmp/fcitx5-rime-backup
```

### 2. 安装依赖

检测发行版并安装对应包：

| 发行版 | 命令 |
|--------|------|
| Ubuntu/Debian/Pop!_OS | `sudo apt install -y fcitx5 fcitx5-rime fcitx5-material-color` |
| Fedora | `sudo dnf install -y fcitx5 fcitx5-rime fcitx5-material-color` |
| Arch/Manjaro | `sudo pacman -S --noconfirm fcitx5 fcitx5-rime fcitx5-material-color` |

### 3. 备份已有配置

```bash
backup_dir="/tmp/fcitx5-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$backup_dir"
for f in ~/.config/fcitx5/profile ~/.config/fcitx5/conf/classicui.conf \
         ~/.local/share/fcitx5/rime/default.custom.yaml \
         ~/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml \
         ~/.local/share/fcitx5/rime/user.yaml \
         ~/.local/share/fcitx5/themes/Dark-Material; do
  [ -e "$f" ] && cp -r "$f" "$backup_dir/"
done
```

### 4. 复制配置

```bash
mkdir -p ~/.config/fcitx5/conf ~/.local/share/fcitx5/rime ~/.local/share/fcitx5/themes/Dark-Material

cp /tmp/fcitx5-rime-backup/config/fcitx5/profile ~/.config/fcitx5/profile
cp /tmp/fcitx5-rime-backup/config/fcitx5/conf/classicui.conf ~/.config/fcitx5/conf/classicui.conf
cp /tmp/fcitx5-rime-backup/rime/default.custom.yaml ~/.local/share/fcitx5/rime/default.custom.yaml
cp /tmp/fcitx5-rime-backup/rime/luna_pinyin_simp.custom.yaml ~/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml
cp /tmp/fcitx5-rime-backup/rime/user.yaml ~/.local/share/fcitx5/rime/user.yaml
cp /tmp/fcitx5-rime-backup/themes/Dark-Material/* ~/.local/share/fcitx5/themes/Dark-Material/
cp /tmp/fcitx5-rime-backup/env/xprofile ~/.xprofile
cp /tmp/fcitx5-rime-backup/env/pam_environment ~/.pam_environment
chmod +x ~/.xprofile
```

### 5. 环境变量

确保当前 shell 环境变量生效：

```bash
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
export SDL_IM_MODULE=fcitx5
```

如果 `~/.bashrc` 中没有这些，追加它们。

### 6. 系统配置

```bash
sudo im-config -n fcitx5
# 如果是 Pop!_OS，禁用 ibus 覆盖
[ -f /etc/profile.d/pop-im-ibus.sh ] && sudo mv /etc/profile.d/pop-im-ibus.sh /etc/profile.d/pop-im-ibus.sh.bak
```

### 7. 部署 Rime

```bash
rm -rf ~/.local/share/fcitx5/rime/build/*
rm -f ~/.local/share/fcitx5/rime/default.yaml
rime_deployer --build \
  ~/.local/share/fcitx5/rime \
  /usr/share/rime-data \
  ~/.local/share/fcitx5/rime/build
```

### 8. 重启 Fcitx5

```bash
fcitx5-remote -e 2>/dev/null || pkill fcitx5 2>/dev/null || true
sleep 1
fcitx5 -d --replace &
```

### 9. 完成提示

告知用户：
- 按 `Shift` 切换中/英文
- 按 `` Ctrl + ` `` 切换输入方案
- **重新登录桌面环境**确保所有环境变量生效
