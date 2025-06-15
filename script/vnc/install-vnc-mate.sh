#!/bin/bash

echo "🛠️ 安装 MATE 桌面环境 + TigerVNC 无密码服务"

REAL_USER=$(logname)
USER_HOME=$(eval echo "~$REAL_USER")

# 卸载 tightvnc（如有）
sudo apt purge -y tightvncserver

# 安装 MATE 桌面 和 TigerVNC 及必要组件
sudo apt update
sudo apt install -y ubuntu-mate-core ubuntu-mate-desktop tigervnc-standalone-server xterm dbus-x11

# 初始化 VNC（首次运行建立 ~/.vnc）
sudo -u $REAL_USER vncserver :1
sudo -u $REAL_USER vncserver -kill :1

# 写入 xstartup 脚本（使用 mate-session）
cat <<EOF | sudo tee $USER_HOME/.vnc/xstartup > /dev/null
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session mate-session
EOF

sudo chmod +x $USER_HOME/.vnc/xstartup
sudo chown $REAL_USER:$REAL_USER $USER_HOME/.vnc/xstartup

# 写入 VNC 启动脚本（监听全网 + 无密码）
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
  echo "⚠️ 脚本以 root 运行，未能为普通用户添加 crontab。你可以手动执行："
  echo "   crontab -e"
  echo "   然后添加：@reboot /home/你的用户名/start-vnc.sh"
fi

echo "✅ MATE VNC 安装完成！现在可以通过 VNC Viewer 连接 <IP>:5901"
echo "📌 默认无需密码，适用于局域网开发和远程桌面"
