# VNC 远程桌面安装脚本

这个目录包含了多个用于安装和配置VNC远程桌面的脚本，适用于不同的使用场景。

## 脚本说明

### 1. `vnc.sh` - 通用VNC安装脚本（推荐）
- **用途**: 安装XFCE桌面环境 + TigerVNC无密码服务
- **特点**: 
  - 支持root和普通用户环境
  - 自动配置开机启动（root用systemd，普通用户用crontab）
  - 无密码访问，仅限局域网使用
  - 端口：5901
- **适用场景**: 大多数Linux发行版，特别是服务器环境

### 2. `install-tigervnc-no-password.sh` - TigerVNC专用脚本
- **用途**: 专门安装TigerVNC + XFCE桌面
- **特点**: 
  - 使用TigerVNC服务器
  - 无密码访问
  - 端口：5901
- **适用场景**: 需要更稳定VNC服务的环境

### 3. `install-vnc-mate.sh` - MATE桌面VNC脚本
- **用途**: 安装MATE桌面环境 + TigerVNC
- **特点**: 
  - 使用MATE桌面环境（更轻量）
  - 无密码访问
  - 端口：5901
- **适用场景**: 资源有限的服务器或喜欢MATE桌面的用户

## 使用方法

### 快速安装（推荐）
```bash
# 下载并执行通用脚本
wget https://raw.githubusercontent.com/your-repo/Script-Collection/main/script/vnc/vnc.sh
chmod +x vnc.sh
sudo ./vnc.sh
```

### 手动安装
```bash
# 1. 给脚本执行权限
chmod +x *.sh

# 2. 选择并执行脚本
sudo ./vnc.sh                    # 通用版本
sudo ./install-tigervnc-no-password.sh  # TigerVNC版本
sudo ./install-vnc-mate.sh       # MATE版本
```

## 连接方法

安装完成后，使用VNC客户端连接：
- **地址**: `你的服务器IP:5901`
- **密码**: 无需密码
- **推荐客户端**: 
  - Windows: VNC Viewer, RealVNC Viewer
  - macOS: VNC Viewer, Screen Sharing
  - Linux: Remmina, Vinagre

## 故障排除

### 常见问题

1. **重启后VNC不工作**
   - 检查防火墙是否开放5901端口
   - 确认自动启动服务是否启用
   - 查看日志：`sudo journalctl -u vnc-server.service`

2. **连接被拒绝**
   - 确认VNC服务正在运行：`ps aux | grep vnc`
   - 检查端口是否监听：`netstat -tlnp | grep 5901`

3. **桌面环境问题**
   - 重新安装桌面环境：`sudo apt install --reinstall xfce4`
   - 检查xstartup文件权限

### 手动启动VNC
```bash
# 如果自动启动失败，可以手动启动
sudo -u 用户名 /home/用户名/start-vnc.sh
```

## 安全注意事项

⚠️ **重要**: 这些脚本配置为无密码访问，仅适用于：
- 受信任的局域网环境
- 开发和测试环境
- 临时使用场景

**生产环境建议**:
- 启用VNC密码认证
- 使用SSH隧道连接
- 配置防火墙规则
- 定期更新系统和VNC软件

## 卸载VNC

```bash
# 停止并禁用服务
sudo systemctl stop vnc-server.service
sudo systemctl disable vnc-server.service

# 删除服务文件
sudo rm /etc/systemd/system/vnc-server.service

# 卸载软件包
sudo apt purge tigervnc-standalone-server xfce4 xfce4-goodies
sudo apt autoremove

# 清理用户配置
rm -rf ~/.vnc
rm ~/start-vnc.sh
```
