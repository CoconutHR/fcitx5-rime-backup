# 🖤 Fcitx5 Rime 配置包

> 暗色主题 · 朙月拼音·简化字 · 一键迁移

一套开箱即用的 **Fcitx5 Rime** 输入法配置，包含：

- 🎨 **Dark-Material 深色主题** — 黑底灰字，护眼美观
- 🔵 **Material-Color-blue 主题**（备选）— 白底蓝边，清爽风格
- 📝 **朙月拼音·简化字** + **地球拼音** 双方案
- 🔢 **9 个候选词**，横向排列
- ⚡ **一键安装脚本**，跨发行版支持

## 快速开始

### 一键安装（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/CoconutHR/fcitx5-rime-backup/main/setup.sh)
```

脚本会自动完成：
1. 安装 `fcitx5`、`fcitx5-rime` 及主题包
2. 备份你现有的配置
3. 部署深色主题和输入法设置
4. 配置系统环境变量
5. 重启 Fcitx5

### 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/CoconutHR/fcitx5-rime-backup.git
cd fcitx5-rime-backup

# 2. 安装依赖
sudo apt install fcitx5 fcitx5-rime fcitx5-material-color

# 3. 复制配置
cp -r config/fcitx5/* ~/.config/fcitx5/
cp -r rime/* ~/.local/share/fcitx5/rime/
cp -r themes/Dark-Material ~/.local/share/fcitx5/themes/
cp env/xprofile ~/.xprofile
cp env/pam_environment ~/.pam_environment
chmod +x ~/.xprofile

# 4. 系统配置
sudo im-config -n fcitx5

# 5. 部署 Rime
rime_deployer --build \
  ~/.local/share/fcitx5/rime \
  /usr/share/rime-data \
  ~/.local/share/fcitx5/rime/build

# 6. 重启 fcitx5
pkill fcitx5
fcitx5 -d --replace &

# 7. 重新登录桌面环境
```

## 包含内容

| 文件 | 说明 |
|------|------|
| `config/fcitx5/profile` | 分组布局：Rime 为默认分组 |
| `config/fcitx5/conf/classicui.conf` | 界面主题 = Dark-Material，字体 Noto Sans CJK SC 13 |
| `rime/default.custom.yaml` | 启用 luna_pinyin_simp + terra_pinyin |
| `rime/luna_pinyin_simp.custom.yaml` | 9 候选词、横向排列、字号 10 |
| `rime/user.yaml` | 默认使用 luna_pinyin_simp，简化字模式开 |
| `themes/Dark-Material/` | 自制的深色主题（黑底 + 灰字 + 蓝高亮） |
| `env/xprofile` | 环境变量：GTK_IM_MODULE=fcitx5 等 |
| `env/pam_environment` | PAM 级环境变量备份 |
| `setup.sh` | 一键安装脚本 |

## 快捷键

| 按键 | 功能 |
|------|------|
| `Shift` | 中/英文切换 |
| `Ctrl + \`` | 切换输入方案（luna_pinyin_simp / terra_pinyin） |
| `Ctrl + Shift + 4` | 切换繁/简体 |
| `Super + 空格` | 切换输入法分组 |

## 截图

> *（后续补上截图）*

## 许可证

MIT
