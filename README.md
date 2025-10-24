# 🌐 NJUPT AutoLogin
很久以前基于前辈的个人调整版本，可挂在openwrt上使用。已不在校内住宿，仅作记录和参考

<div align="center">
  
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
  [![Version](https://img.shields.io/badge/version-1.1.1-green.svg)](CHANGELOG.md)
  [![Stars](https://img.shields.io/github/stars/yourusername/NJUPT-AutoLogin.svg)](https://github.com/yourusername/NJUPT-AutoLogin/stargazers)
  
  南京邮电大学校园网自动登录脚本
  
  [功能特性](#-功能特性) • [快速开始](#-快速开始) • [使用文档](#-使用文档) • [常见问题](#-常见问题)
  
</div>

---

本项目是基于 [NuoTian](https://github.com/s235784) 的 [NJUPT_AutoLogin](https://github.com/s235784/NJUPT_AutoLogin) 进行二次开发的版本。

**原作者：** NuoTian (https://github.com/s235784)  
**原项目：** https://github.com/s235784/NJUPT_AutoLogin

感谢原作者的开源贡献！🙏

## ✨ 功能特性

- 🚀 **一键登录** - 简单快捷的校园网认证
- 🔄 **自动重连** - 网络断开自动恢复
- ⏰ **时间控制** - 支持设定登录时间段
- 🏢 **多ISP支持** - 支持校园网/电信/移动
- 🏫 **双校区支持** - 仙林/三牌楼校区
- 📱 **多平台** - 支持路由器/Linux/macOS

## 🎯 适用场景

- ✅ 宿舍路由器自动登录（OpenWrt/梅林等）
- ✅ 树莓派/软路由自动认证
- ✅ 开机自动连接校园网

## 🚀 快速开始

### 基础使用
```bash
# 1. 下载脚本
wget https://raw.githubusercontent.com/yourusername/NJUPT-AutoLogin/main/scripts/NJUPT-AutoLogin.sh

# 2. 添加执行权限
chmod +x NJUPT-AutoLogin.sh

# 3. 登录（电信用户示例）
./NJUPT-AutoLogin.sh -i ctcc 学号 密码

# 4. 登出
./NJUPT-AutoLogin.sh -o
```

### OpenWrt路由器部署
```bash
# 使用一键安装脚本
wget -O install.sh https://raw.githubusercontent.com/yourusername/NJUPT-AutoLogin/main/scripts/install.sh
bash install.sh
```

## 📖 使用文档

### 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `-e` | 网络接口 | `-e wan` |
| `-i` | 运营商 | `-i ctcc` |
| `-l` | 时间限制 | `-l` |
| `-s` | 三牌楼校区 | `-s` |
| `-d` | 忽略网线错误 | `-d` |
| `-o` | 登出 | `-o` |

### 运营商选择

- `njupt` - 校园网（默认）
- `ctcc` - 中国电信
- `cmcc` - 中国移动

### 示例命令
```bash
# 电信用户登录（仙林校区）
./NJUPT-AutoLogin.sh -e wan -i ctcc B21012250 password123

# 校园网登录（三牌楼校区）
./NJUPT-AutoLogin.sh -e eth0 -i njupt -s B21012250 password123

# 带时间限制的登录
./NJUPT-AutoLogin.sh -e wan -i ctcc -l B21012250 password123
```

## ⚙️ 进阶配置

### 1. 设置定时任务（每5分钟检查一次）
```bash
# 编辑crontab
crontab -e

# 添加以下内容
*/5 * * * * /root/NJUPT-AutoLogin.sh -i ctcc 学号 密码 >> /var/log/autologin.log 2>&1
```

### 2. 开机自动运行（OpenWrt）
```bash
# 编辑 /etc/rc.local
vi /etc/rc.local

# 在 exit 0 之前添加
/root/NJUPT-AutoLogin.sh -i ctcc 学号 密码 &
```

### 3. Systemd服务（Linux系统）

创建服务文件详见：[docs/installation.md](docs/installation.md)

## ⚠️ 注意事项

- 🔒 **密码安全**：建议修改脚本使用配置文件存储密码
- 🌐 **IP变化**：学校可能更改认证服务器IP，请留意更新
- ⏰ **时间同步**：确保设备时间准确，否则时间限制功能可能失效
- 📱 **多设备**：避免多设备同时使用同一账号

## 🐛 故障排除

### 无法获取IP地址
```bash
# 检查网络接口
ifconfig
# 或
ip addr show
```

### 登录失败
1. 确认账号密码正确
2. 检查运营商参数（-i）
3. 确认校区设置（-s）
4. 查看详细错误信息

更多问题请查看 [FAQ文档](docs/faq.md)

## 📊 更新日志

### v1.1.1 (当前版本)
- 优化错误处理
- 添加详细日志输出
- 修复时间限制bug

查看完整更新记录：[CHANGELOG.md](CHANGELOG.md)


## 📜 开源许可

本项目采用 [MIT License](LICENSE) 开源协议


## 📮 联系方式

- GitHub Issues: [提交问题](https://github.com/yourusername/NJUPT-AutoLogin/issues)

