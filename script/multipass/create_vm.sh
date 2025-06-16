#!/bin/bash

# ========== 基本配置 ==========
PASSWORD="123456"
CPU=2
RAM=4G
DISK=30G

# ========== 自动命名 or 手动指定 ==========
DATE=$(date +%Y%m%d)
RAND=$(printf "%03d" $((RANDOM % 1000)))
DEFAULT_NAME="devbox-$DATE-$RAND"
VM_NAME=${1:-$DEFAULT_NAME}

# ========== 名称合法性检查 ==========
if [[ ! "$VM_NAME" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
  echo "❌ 无效的虚拟机名称：$VM_NAME"
  exit 1
fi

# ========== 创建虚拟机 ==========
multipass launch --name "$VM_NAME" \
  --cpus "$CPU" --memory "$RAM" --disk "$DISK" \
  --cloud-init - <<EOF
#cloud-config
ssh_pwauth: true

users:
  - name: ubuntu
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash

chpasswd:
  list: |
    ubuntu:${PASSWORD}
  expire: false

write_files:
  - path: /etc/resolv.conf
    permissions: '0644'
    content: |
      nameserver 8.8.8.8
      nameserver 1.1.1.1
      options edns0
EOF

echo "✅ VM '$VM_NAME' 已创建完毕"
echo "🔐 SSH 密码: $PASSWORD"
echo "💻 SSH 登录: ssh ubuntu@$(multipass info $VM_NAME | awk '/IPv4/ {print $2}')"
