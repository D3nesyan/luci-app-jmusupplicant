#已有方法可以直接绕过断网，以及多设备检测。这个 Luci app 可以埋了

Openwrt/LEDE LuCI for JMUSupplicant
===

简介
---
本软件包是 jmusupplicant 的 LuCI 控制界面，适用于集美大学校园网的锐捷认证。

注意
---
本 LuCI 应用依赖 jmusupplicant。</br>
请安装通过下面教程编译出的 2 个 ipk 文件。(jmusupplicant & luci-app-jmusupplicant)

编译
---
```bash
#进入 OpenWrt 源码 package 目录
$ cd package
#克隆依赖
$ git clone https://github.com/D3nesyan/jmuSupplicant-OpenWrt-ipk.git jmusupplicant
#克隆插件源码
$ git clone https://github.com/D3nesyan/luci-app-jmusupplicant.git
#返回上一层目录
$ cd ..
#配置
$ make menuconfig
#在 luci -> application 选中插件，开始编译
$ make package/luci-app-jmusupplicant/compile V=s
```

功能
---
- #### 自动重连
1. 开启自动重连功能后，将会在每天 6:10 重新连接至运营商宽带网络，并关闭断网模式。
2. 在周日到周四的 23:00，开始检测是否断网。一旦检测到网络断开，将会打开断网模式并自动重连。
3. 在周五和周六的 23:59, 开始检测是否断网。一旦检测到网络断开，将会打开断网模式并自动重连。

- #### 自定义连接时使用的 IP 地址，网关，子网遮罩和 DNS 地址

声明
---
本项目基于 [luci-app-mentohust](https://github.com/immortalwrt/luci/commits/master/applications/luci-app-mentohust) 进行二次开发。
