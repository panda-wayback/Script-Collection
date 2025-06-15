#!/bin/bash

echo "🔓 安装无密码 VNC（仅限局域网使用）"

# 安装基础组件
sudo apt update && sudo apt upgrade -y
sudo apt install -y xfce4 xfce4-goodies tightvncserver x11vnc

# 检查当前用户（防止 sudo 下写入 root 目录）
REAL_USER=$(logname)
AUTOSTART_DIR="/home/$REAL_USER/.config/autostart"

# 修复权限问题（有些人之前用 sudo 写过）
sudo mkdir -p "$AUTOSTART_DIR"
sudo chown -R "$REAL_USER:$REAL_USER" "/home/$REAL_USER/.config"

# 写入 x11vnc 自动启动配置
cat > "$AUTOSTART_DIR/x11vnc.desktop" <<EOF
[Desktop Entry]
Name=X11VNC
Exec=x11vnc -forever -display :0 -auth guess -nopw -shared
Type=Application
EOF

echo "✅ 设置完成，重启系统后将自动启动 VNC 服务，允许无密码访问"
echo "👉 建议你使用 VNC Viewer 连接 <设备IP>:5900，无需密码"
