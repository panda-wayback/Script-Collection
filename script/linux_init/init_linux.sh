#!/bin/bash

# 检测操作系统类型
OS="$(uname -s)"

echo "开始系统更新和 Git 安装..."

if [[ "$OS" == "Linux" ]]; then
    echo "正在为 Linux 系统更新并安装 Git..."

    # 更新系统包
    sudo apt update && sudo apt upgrade -y
    if [ $? -ne 0 ]; then
      echo "系统包更新失败，请检查你的网络连接和软件源配置。" >&2
      exit 1
    fi
    echo "系统包已更新。"

    # 安装 Git（如果未安装）
    if ! command -v git &> /dev/null; then
        echo "正在安装 Git..."
        sudo apt-get update
        sudo apt-get install git -y
        if [ $? -ne 0 ]; then
          echo "Git 安装失败。" >&2
          exit 1
        fi
        echo "Git 已安装。"
    else
        echo "Git 已安装，跳过此步骤。"
    fi

elif [[ "$OS" == "Darwin" ]]; then
    echo "正在为 macOS 系统更新并安装 Git..."

    # 检查并安装 Homebrew（如果未安装）
    if ! command -v brew &>/dev/null; then
        echo "Homebrew 未安装，正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)"
        if [ $? -ne 0 ]; then
            echo "Homebrew 安装失败。" >&2
            exit 1
        fi
        echo "Homebrew 已安装。"
    fi

    # 更新 Homebrew
    echo "正在更新 Homebrew..."
    brew update
    brew upgrade

    # 安装 Git（如果未安装）
    if ! command -v git &> /dev/null; then
        echo "正在安装 Git..."
        brew install git
        if [ $? -ne 0 ]; then
          echo "Git 安装失败。" >&2
          exit 1
        fi
        echo "Git 已安装。"
    else
        echo "Git 已安装，跳过此步骤。"
    fi

else
    echo "此脚本仅支持 Linux 和 macOS 系统。"
    exit 1
fi

echo "系统更新和 Git 安装完成。"
