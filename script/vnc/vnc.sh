#!/bin/bash

echo "🔓 安装无密码 VNC（仅限局域网使用）"

# 获取真实用户（修复root环境下的问题）
if [ "$USER" = "root" ]; then
    # 在root环境下，尝试多种方法获取真实用户
    if [ -n "$SUDO_USER" ]; then
        REAL_USER="$SUDO_USER"
    elif [ -n "$LOGNAME" ]; then
        REAL_USER="$LOGNAME"
    else
        # 如果都无法获取，使用第一个非root用户
        REAL_USER=$(grep -v '^root:' /etc/passwd | grep -v '^nobody:' | head -1 | cut -d: -f1)
        if [ -z "$REAL_USER" ]; then
            echo "❌ 无法确定真实用户，请手动指定用户名"
            echo "使用方法: REAL_USER=你的用户名 ./vnc.sh"
            exit 1
        fi
        echo "⚠️ 自动检测到用户: $REAL_USER"
    fi
else
    REAL_USER="$USER"
fi

USER_HOME=$(eval echo "~$REAL_USER")

echo "👤 使用用户: $REAL_USER"
echo "🏠 用户目录: $USER_HOME"

# 安装基础组件
sudo apt update && sudo apt upgrade -y
sudo apt install -y xfce4 xfce4-goodies tigervnc-standalone-server xterm dbus-x11

# 卸载可能冲突的 tightvnc
sudo apt purge -y tightvncserver

# 清理现有的 VNC 配置
rm -rf $USER_HOME/.vnc
sudo -u $REAL_USER mkdir -p $USER_HOME/.vnc

# 初始化 vnc 配置目录（使用无密码模式）
sudo -u $REAL_USER vncserver -kill :1 > /dev/null 2>&1
sudo -u $REAL_USER vncserver :1 -SecurityTypes None -localhost no --I-KNOW-THIS-IS-INSECURE
sudo -u $REAL_USER vncserver -kill :1

# 写入 xstartup 脚本（使用 dbus-launch，避免会话失败）
cat <<EOF | sudo tee $USER_HOME/.vnc/xstartup > /dev/null
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
EOF

sudo chmod +x $USER_HOME/.vnc/xstartup
sudo chown $REAL_USER:$REAL_USER $USER_HOME/.vnc/xstartup

# 写入 VNC 启动脚本（无密码 + 监听外部）
cat <<EOF | sudo tee $USER_HOME/start-vnc.sh > /dev/null
#!/bin/bash
vncserver -kill :1 > /dev/null 2>&1
vncserver :1 -SecurityTypes None -localhost no --I-KNOW-THIS-IS-INSECURE
EOF

sudo chmod +x $USER_HOME/start-vnc.sh
sudo chown $REAL_USER:$REAL_USER $USER_HOME/start-vnc.sh

# 添加自动启动（修复版 - 支持root环境）
if [ "$USER" != "root" ]; then
  # 普通用户：使用crontab
  crontab -l 2>/dev/null | grep -v start-vnc.sh > /tmp/crontab.vnc.tmp
  echo "@reboot $HOME/start-vnc.sh" >> /tmp/crontab.vnc.tmp
  crontab /tmp/crontab.vnc.tmp
  rm /tmp/crontab.vnc.tmp
  echo "🔁 已添加开机自动启动到当前用户 crontab"
else
  # Root用户：使用systemd服务
  cat <<EOF | sudo tee /etc/systemd/system/vnc-server.service > /dev/null
[Unit]
Description=VNC Server
After=network.target

[Service]
Type=forking
User=$REAL_USER
WorkingDirectory=$USER_HOME
ExecStart=$USER_HOME/start-vnc.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable vnc-server.service
  echo "🔁 已添加开机自动启动到systemd服务"
fi

echo "✅ 设置完成，重启系统后将自动启动 VNC 服务，允许无密码访问"
echo "👉 建议你使用 VNC Viewer 连接 <设备IP>:5901，无需密码"
echo "📌 注意：请确保防火墙允许 5901 端口访问"
