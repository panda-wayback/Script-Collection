#!/bin/bash

# 检测系统类型
OS="$(uname -s)"

# 安全提示
echo "请确保你拥有 sudo 权限并已输入密码。"

if [[ "$OS" == "Linux" ]]; then
    echo "正在为 Linux 系统安装..."

    # 更新系统包
    echo "正在更新系统包..."
    sudo apt update && sudo apt upgrade -y
    if [ $? -ne 0 ]; then
      echo "系统包更新失败，请检查你的网络连接和软件源配置。" >&2
      exit 1
    fi
    echo "系统包已更新。"

    # 安装 curl（如果未安装）
    if ! command -v curl &> /dev/null; then
      echo "正在安装 curl..."
      sudo apt install curl -y
      if [ $? -ne 0 ]; then
        echo "curl 安装失败。" >&2
        exit 1
      fi
      echo "curl 已安装。"
    else
      echo "curl 已安装，跳过此步骤。"
    fi

elif [[ "$OS" == "Darwin" ]]; then
    echo "正在为 macOS 系统安装..."

    # 检查并安装 Homebrew（如果未安装）
    if ! command -v brew &>/dev/null; then
        echo "Homebrew 未安装，正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        #  /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
        if [ $? -ne 0 ]; then
            echo "Homebrew 安装失败。" >&2
            exit 1
        fi
        echo "Homebrew 已安装。"
    fi

    # 更新 Homebrew
    echo "正在更新 Homebrew..."
    brew update
fi

# 安装 NVM
echo "正在安装 NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
if [ $? -ne 0 ]; then
  echo "NVM 安装失败。" >&2
  exit 1
fi
echo "NVM 已安装。"

# 加载 NVM 到当前 shell 会话
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || { echo "无法加载 NVM。" >&2; exit 1; }

echo "NVM 已成功安装，您可以立即使用 NVM。"

# 安装 Node.js 20
echo "正在安装 Node.js 20..."
nvm install 20
if [ $? -ne 0 ]; then
  echo "Node.js 20 安装失败。" >&2
  exit 1
fi
echo "Node.js 20 已安装。"

# 设置 Node.js 20 为默认版本
nvm alias default 20
if [ $? -ne 0 ]; then
  echo "无法设置 Node.js 20 为默认版本。" >&2
  exit 1
fi
echo "Node.js 20 已设置为默认版本。"

# 安装 Yarn
echo "正在安装 Yarn..."
if [[ "$OS" == "Linux" ]]; then
    npm install -g yarn
else
    brew install yarn
fi

if [ $? -ne 0 ]; then
  echo "Yarn 安装失败。" >&2
  exit 1
fi
echo "Yarn 已安装。"

# 安装 pnpm
echo "正在安装 pnpm..."
npm install -g pnpm
if [ $? -ne 0 ]; then
  echo "pnpm 安装失败。" >&2
  exit 1
fi
echo "pnpm 已安装。"

# 安装 pm2
echo "正在安装 pm2..."
npm install -g pm2
if [ $? -ne 0 ]; then
  echo "pm2 安装失败。" >&2
  exit 1
fi
echo "pm2 已安装。"

# 加载 Homebrew 到当前 shell 会话（仅 macOS）
if [[ "$OS" == "Darwin" ]]; then
    echo "正在加载 Homebrew..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if [ $? -ne 0 ]; then
      echo "无法加载 Homebrew。" >&2
      exit 1
    fi
    echo "Homebrew 已加载。"
fi

echo "所有安装步骤已完成。您现在可以使用 NVM、Node.js、Yarn、pnpm 和 pm2。"