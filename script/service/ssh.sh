#!/bin/bash

# 显示帮助信息
show_help() {
    echo "SSH 公钥复制工具"
    echo ""
    echo "使用方法: $0 [选项] <用户名@主机名>"
    echo ""
    echo "选项:"
    echo "  -p, --port     SSH 端口 (默认: 22)"
    echo "  -h, --help     显示此帮助信息"
    echo ""
    echo "参数:"
    echo "  用户名@主机名   目标主机的用户名和主机名"
    echo ""
    echo "示例:"
    echo "  $0 user@example.com"
    echo "  $0 -p 2222 admin@192.168.1.100"
    echo "  $0 admin@192.168.1.100 -p 2222"
    echo ""
    echo "说明:"
    echo "  此脚本会自动将本地的 SSH 公钥复制到目标主机，实现无密码 SSH 登录。"
    echo "  脚本会优先使用 ~/.ssh/id_ed25519.pub，如果不存在则使用 ~/.ssh/id_rsa.pub。"
    echo ""
}

# 解析参数
PORT=22
PARAMS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -p|--port)
      if [[ -n "$2" && ! "$2" =~ ^- ]]; then
        PORT="$2"
        shift 2
      else
        echo "错误: --port 选项需要一个端口号参数" >&2
        exit 1
      fi
      ;;
    *)
      PARAMS+=("$1")
      shift
      ;;
  esac
done

SSH_USER_HOST=${PARAMS[0]}

# 检查是否提供了目标主机参数
if [ -z "$SSH_USER_HOST" ]; then
    echo "错误: 缺少目标主机参数"
    echo ""
    show_help
    exit 1
fi

# 自动检测公钥文件
if [ -f ~/.ssh/id_ed25519.pub ]; then
    PUB_KEY_PATH=~/.ssh/id_ed25519.pub
elif [ -f ~/.ssh/id_rsa.pub ]; then
    PUB_KEY_PATH=~/.ssh/id_rsa.pub
else
    echo "错误: 未找到 SSH 公钥文件 (~/.ssh/id_ed25519.pub 或 ~/.ssh/id_rsa.pub)"
    echo "请先使用 'ssh-keygen -t ed25519' 或 'ssh-keygen -t rsa' 生成 SSH 密钥对"
    exit 1
fi

echo "使用公钥: $PUB_KEY_PATH"
echo "正在复制 SSH 公钥到 $SSH_USER_HOST (端口: $PORT)..."

# 执行 ssh-copy-id 命令并捕获输出
output=$(ssh-copy-id -p "$PORT" -i "$PUB_KEY_PATH" "$SSH_USER_HOST" 2>&1)
exit_code=$?

# 检查命令执行结果
if [ $exit_code -eq 0 ]; then
    if echo "$output" | grep -q "WARNING: All keys were skipped because they already exist on the remote system."; then
        echo "⚠️  警告: 公钥已存在于目标主机上。"
        echo "   SSH 公钥已成功复制到 $SSH_USER_HOST"
        echo ""
        echo "💡 如果您仍然无法免密登录，请检查目标服务器的以下配置："
        echo "   1. SSH 配置文件 (/etc/ssh/sshd_config):"
        echo "      - 确保 PubkeyAuthentication yes"
        echo "      - 如果以 root 登录, 确保 PermitRootLogin yes (或 prohibit-password)"
        echo "   2. 检查文件权限:"
        echo "      - chmod 700 ~/.ssh"
        echo "      - chmod 600 ~/.ssh/authorized_keys"
        echo "   3. 检查SSH服务端口是否正确。"
    else
        echo "✅ SSH 公钥已成功复制到 $SSH_USER_HOST"
        echo "现在您可以使用 'ssh -p $PORT $SSH_USER_HOST' 无需密码登录"
    fi
else
    echo "❌ 复制 SSH 公钥失败，请检查以下信息："
    echo "   - 目标主机是否可访问"
    echo "   - 用户名和密码是否正确"
    echo "   - SSH 端口号是否正确"
    echo ""
    echo "详细错误信息:"
    echo "$output"
    exit 1
fi
