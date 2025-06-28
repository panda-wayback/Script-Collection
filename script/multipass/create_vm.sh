#!/bin/bash

# =========== 使用方法 ===========
# 1. 创建虚拟机（使用默认参数）
# ./create_vm.sh
# 2. 创建虚拟机并指定名称
# ./create_vm.sh devbox-20250627-001
# 3. 创建虚拟机并指定名称和密码
# ./create_vm.sh devbox-20250627-001 123456
# 4. 创建虚拟机并指定名称和密码和CPU和内存和硬盘
# ./create_vm.sh devbox-20250627-001 123456 2 4G 30G
# 5. 创建root用户虚拟机（支持多种方式）
# ./create_vm.sh --root devbox-20250627-001 123456 2 4G 30G
# ./create_vm.sh -r devbox-20250627-001 123456 2 4G 30G
# ./create_vm.sh devbox-20250627-001 --root 123456 2 4G 30G

# ========== 帮助信息 ==========
show_help() {
  echo "使用方法: $0 [选项] [VM_NAME] [PASSWORD] [CPU] [RAM] [DISK]"
  echo ""
  echo "选项:"
  echo "  -r, --root    创建默认用户为root的虚拟机"
  echo "  -h, --help    显示此帮助信息"
  echo ""
  echo "参数说明:"
  echo "  VM_NAME  虚拟机名称 (默认: devbox-YYYYMMDD-XXX)"
  echo "  PASSWORD SSH密码 (默认: 123456)"
  echo "  CPU      CPU核心数 (默认: 2)"
  echo "  RAM      内存大小 (默认: 4G)"
  echo "  DISK     硬盘大小 (默认: 30G)"
  echo ""
  echo "示例:"
  echo "  $0                                    # 使用所有默认参数"
  echo "  $0 my-vm                             # 指定名称"
  echo "  $0 my-vm mypass                      # 指定名称和密码"
  echo "  $0 my-vm mypass 4 8G 50G            # 指定所有参数"
  echo "  $0 --root my-vm mypass 2 4G 30G     # 创建root用户虚拟机"
  echo "  $0 -r my-vm mypass 2 4G 30G         # 创建root用户虚拟机（短选项）"
  echo "  $0 my-vm --root mypass 2 4G 30G     # 创建root用户虚拟机（位置灵活）"
  echo ""
}

# ========== 参数处理 ==========
ROOT_MODE=false
HELP_MODE=false

# 处理所有参数，过滤掉选项
PARAMS=()
for arg in "$@"; do
  case $arg in
    -h|--help)
      HELP_MODE=true
      ;;
    -r|--root)
      ROOT_MODE=true
      ;;
    *)
      PARAMS+=("$arg")
      ;;
  esac
done

# 显示帮助信息
if [ "$HELP_MODE" = true ]; then
  show_help
  exit 0
fi

# ========== 默认配置 ==========
DEFAULT_PASSWORD="123456"
DEFAULT_CPU=2
DEFAULT_RAM="4G"
DEFAULT_DISK="30G"

# ========== 自动命名 ==========
DATE=$(date +%Y%m%d)
RAND=$(printf "%03d" $((RANDOM % 1000)))
DEFAULT_NAME="devbox-$DATE-$RAND"

# ========== 参数赋值 ==========
VM_NAME=${PARAMS[0]:-$DEFAULT_NAME}
PASSWORD=${PARAMS[1]:-$DEFAULT_PASSWORD}
CPU=${PARAMS[2]:-$DEFAULT_CPU}
RAM=${PARAMS[3]:-$DEFAULT_RAM}
DISK=${PARAMS[4]:-$DEFAULT_DISK}

# ========== 参数验证 ==========

# 名称合法性检查
if [[ ! "$VM_NAME" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
  echo "❌ 无效的虚拟机名称：$VM_NAME"
  echo "   名称必须以字母开头，只能包含字母、数字和连字符"
  exit 1
fi

# 检查虚拟机是否已存在
if multipass list | grep -q "^$VM_NAME "; then
  echo "❌ 虚拟机 '$VM_NAME' 已存在"
  exit 1
fi

# CPU验证
if ! [[ "$CPU" =~ ^[0-9]+$ ]] || [ "$CPU" -lt 1 ] || [ "$CPU" -gt 16 ]; then
  echo "❌ 无效的CPU核心数：$CPU"
  echo "   CPU核心数必须是1-16之间的整数"
  exit 1
fi

# 内存验证
if ! [[ "$RAM" =~ ^[0-9]+[MG]$ ]]; then
  echo "❌ 无效的内存大小：$RAM"
  echo "   内存格式应为数字+M或数字+G，如：2G, 512M"
  exit 1
fi

# 硬盘验证
if ! [[ "$DISK" =~ ^[0-9]+[MG]$ ]]; then
  echo "❌ 无效的硬盘大小：$DISK"
  echo "   硬盘格式应为数字+M或数字+G，如：30G, 512M"
  exit 1
fi

# 密码长度验证
if [ ${#PASSWORD} -lt 6 ]; then
  echo "❌ 密码长度不足：$PASSWORD"
  echo "   密码长度至少为6位"
  exit 1
fi

# ========== 显示配置信息 ==========
echo "🚀 开始创建虚拟机..."
echo "📋 配置信息:"
echo "   名称: $VM_NAME"
echo "   CPU: $CPU 核心"
echo "   内存: $RAM"
echo "   硬盘: $DISK"
echo "   密码: $PASSWORD"
if [ "$ROOT_MODE" = true ]; then
  echo "   用户: root"
else
  echo "   用户: ubuntu"
fi
echo ""

# ========== 创建虚拟机 ==========
echo "⏳ 正在创建虚拟机，请稍候..."

# 根据模式生成不同的cloud-init配置
if [ "$ROOT_MODE" = true ]; then
  # Root用户模式配置
  multipass launch --name "$VM_NAME" \
    --cpus "$CPU" --memory "$RAM" --disk "$DISK" \
    --cloud-init - <<EOF
#cloud-config
ssh_pwauth: true
disable_root: false
ssh_authorized_keys: []

users:
  - name: root
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_pwauth: true

chpasswd:
  list: |
    root:${PASSWORD}
  expire: false

ssh_pwauth: true
disable_root: false

write_files:
  - path: /etc/ssh/sshd_config.d/allow_root.conf
    permissions: '0644'
    content: |
      PermitRootLogin yes
      PasswordAuthentication yes
  - path: /etc/resolv.conf
    permissions: '0644'
    content: |
      nameserver 8.8.8.8
      nameserver 1.1.1.1
      options edns0

runcmd:
  - systemctl restart ssh
EOF
else
  # 默认ubuntu用户模式配置
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
fi

# ========== 检查创建结果 ==========
if [ $? -eq 0 ]; then
  echo ""
  echo "✅ 虚拟机 '$VM_NAME' 创建成功！"
  echo "🔐 SSH 密码: $PASSWORD"
  
  # 获取IP地址
  VM_IP=$(multipass info "$VM_NAME" | awk '/IPv4/ {print $2}')
  if [ -n "$VM_IP" ]; then
    if [ "$ROOT_MODE" = true ]; then
      echo "💻 SSH 登录: ssh root@$VM_IP"
    else
      echo "💻 SSH 登录: ssh ubuntu@$VM_IP"
    fi
    echo "🌐 或者使用: multipass shell $VM_NAME"
  else
    echo "💻 使用: multipass shell $VM_NAME"
  fi
  
  echo ""
  echo "📊 虚拟机信息:"
  multipass info "$VM_NAME"
else
  echo "❌ 虚拟机创建失败"
  exit 1
fi
