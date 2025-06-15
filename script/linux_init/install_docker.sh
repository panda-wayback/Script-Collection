#!/bin/bash

# 检查操作系统类型
OS="$(uname -s)"

if [[ "$OS" == "Linux" ]]; then
    echo "正在为 Linux 系统安装 Docker..."

    # 更新系统包
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # 自动安装 Docker
    curl -fsSL https://get.docker.com | bash -s docker

    # 将当前用户添加到 Docker 组
    sudo usermod -aG docker $USER

    # 刷新用户组权限，避免重新登录
    newgrp docker

    # 检查 Docker 是否安装成功
    docker --version
    echo "Docker 已成功安装。"

    # 安装 Docker Compose 插件
    sudo apt-get install -y docker-compose-plugin

    # 检查 Docker Compose 是否安装成功
    docker compose version
    echo "Docker Compose 已成功安装并配置。"

elif [[ "$OS" == "Darwin" ]]; then
    echo "正在为 macOS 系统安装 Docker..."

    # # 检查并安装 Homebrew（如果未安装）
    # if ! command -v brew &>/dev/null; then
    #     echo "Homebrew 未安装，正在安装 Homebrew..."
    #     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # fi

    # 使用 Homebrew 安装 Docker Desktop
    brew install --cask docker

    # 提示用户启动 Docker Desktop
    echo "请手动启动 Docker Desktop 以完成 Docker 安装。"

    # 等待 Docker Desktop 启动
    while ! docker system info > /dev/null 2>&1; do
        echo "等待 Docker Desktop 启动中..."
        sleep 5
    done

    echo "Docker 已成功安装并启动。"

    # 检查 Docker Compose 版本（Docker Desktop 已包含 Docker Compose）
    docker compose version
    echo "Docker Compose 已成功安装并配置。"

else
    echo "此脚本仅支持 Linux 和 macOS 系统。"
    exit 1
fi

# 提示用户可以使用 Docker Compose 启动项目
echo "您现在可以运行 'docker compose up -d' 来启动 Docker Compose 项目。"
