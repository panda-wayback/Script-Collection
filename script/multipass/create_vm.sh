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
  echo "👉 只能包含字母、数字、连字符（-），不能包含下划线（_）或以数字开头"
  exit 1
fi

# ========== 密码加密 ==========
HASHED_PASS=$(openssl passwd -6 "$PASSWORD")

# ========== 创建虚拟机 ==========
multipass launch --name "$VM_NAME" \
  --cpus "$CPU" --memory "$RAM" --disk "$DISK" \
  --cloud-init - <<EOF
#cloud-config
users:
  - name: ubuntu
    passwd: $HASHED_PASS
    lock_passwd: false
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_pwauth: true

ssh_pwauth: true

write_files:
  - path: /etc/resolv.conf
    permissions: '0644'
    content: |
      nameserver 8.8.8.8
      nameserver 1.1.1.1
      options edns0
EOF

# ========== 输出信息 ==========
echo "✅ Multipass VM '$VM_NAME' 创建完成"
echo "🔐 SSH 密码: $PASSWORD"
echo "🌐 查看 IP: multipass list"
echo "💻 SSH 登录: ssh ubuntu@<IP>（密码: $PASSWORD）"
