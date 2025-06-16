#!/bin/bash

# 检查是否提供了目标主机参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <用户名@主机名>"
    echo "示例: $0 user@example.com"
    exit 1
fi

# 检查 SSH 公钥文件是否存在
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "错误: SSH 公钥文件 (~/.ssh/id_rsa.pub) 不存在"
    echo "请先使用 'ssh-keygen -t rsa' 生成 SSH 密钥对"
    exit 1
fi

# 执行 ssh-copy-id 命令
echo "正在复制 SSH 公钥到 $1..."
ssh-copy-id -i ~/.ssh/id_rsa.pub "$1"

# 检查命令执行结果
if [ $? -eq 0 ]; then
    echo "SSH 公钥已成功复制到 $1"
    echo "现在您可以使用 'ssh $1' 无需密码登录"
else
    echo "复制 SSH 公钥失败，请检查目标主机是否可访问"
    exit 1
fi
