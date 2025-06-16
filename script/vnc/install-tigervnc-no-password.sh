#!/bin/bash

echo "🛠️ 安装 XFCE 桌面环境 + TigerVNC 无密码服务"

REAL_USER=$(logname)
USER_HOME=$(eval echo "~$REAL_USER")

# 卸载 tightvnc（如果之前装过）
sudo apt purge -y tightvncserver

# 安装桌面环境和 TigerVNC
sudo apt update
sudo apt install -y xfce4 xfce4-goodies tigervnc-standalone-server xterm dbus-x11

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

# 添加自动启动（修复版）
if [ "$USER" != "root" ]; then
  crontab -l 2>/dev/null | grep -v start-vnc.sh > /tmp/crontab.vnc.tmp
  echo "@reboot $HOME/start-vnc.sh" >> /tmp/crontab.vnc.tmp
  crontab /tmp/crontab.vnc.tmp
  rm /tmp/crontab.vnc.tmp
  echo "🔁 已添加开机自动启动到当前用户 crontab"
else
  echo "⚠️ 脚本以 root 运行，无法向普通用户 crontab 写入，请手动执行 crontab 添加："
  echo "@reboot /home/你的用户名/start-vnc.sh"
fi

echo "✅ 完成！你现在可以使用 VNC Viewer 连接 <IP>:5901 无需密码"
echo "👉 注意：请确保防火墙允许 5901 端口访问"