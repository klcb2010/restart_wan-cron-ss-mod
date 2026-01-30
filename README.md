# 动态 IPv6 前缀导致远程访问断联的原因及表现（ASUSWRT-Merlin 常见现象）

## 现象描述

在某些地区（尤其是中国大陆、台湾等动态分配 IPv6 的运营商环境），路由器使用 Native 或 Native with DHCP-PD 模式时，经常出现以下情况：

- 路由器内部 ping 国内正常（出网通）
- DDNS status = 1（上报成功）
- 内部用当前 IPv6 地址测试 8443 通（https://[当前IP]:8443）
- 但**远程完全失联**：SSH、SFTP、WebDAV、浏览器访问 DDNS:8443 全超时或连接失败
- 脚本日志显示“状态正常”或“external HTTPS 失败 → 重启 DDNS → 自愈成功”，但实际远程仍挂

## 根本原因

**运营商频繁变更 IPv6 前缀**（Prefix Delegation），导致以下连锁反应：

1. ISP 回收旧前缀，分配新前缀（常见几小时到几天一次）
2. 路由器 WAN 接口获取新 IPv6 地址（CUR_IP 变化）
3. DDNS 服务检测到变化 → 自动上报新地址
4. **ASUS DDNS 服务器同步延迟**（几秒到几分钟，甚至更久）
   - 域名解析（AAAA 记录）仍指向**旧前缀**
   - 外网访问域名时走旧 IP → 连接超时（Connection timed out）
5. 路由器内部测试：
   - 用域名测试（external_https）失败（解析到旧 IP）
   - 用当前 IP 测试（internal_https）成功（本地链路通）
   - ping 国内通（出网正常）
   → 脚本误判为“可自愈”（重启 DDNS 后 status=1），但域名解析没及时更新 → 远程仍挂

**核心矛盾**：路由器“以为”DDNS 成功了，但外部世界看到的还是旧地址。

 典型日志表现

log
异常触发: status=1, IPv6变化=是/否, ping=通, internal=通, external=失败
自动重启 httpd + letsencrypt
修复后 external HTTPS 仍失败 → 重启 DDNS
DDNS重试 1/6: 1
DDNS 自愈成功
状态正常
                                                                
适合梅林原版及改版、官改

运行 <pre><code class="language-html">chmod +x /jffs/scripts/ipv6_watchdog.sh
kill $(ps | grep ipv6_watchdog | grep -v grep | awk '{print $1}') 2>/dev/null
/jffs/scripts/ipv6_watchdog.sh &</code></pre>

查看进程<pre><code class="language-html">ps | grep ipv6_watchdog | grep -v grep</code></pre>

查看日志<pre><code class="language-html">tail -f /jffs/scripts/ipv6_watchdog_$(date +%Y-%m-%d).log</code></pre>


1、定时任务前提条件
   　   安装 <pre><code class="language-html">/usr/sbin/curl -Os https://diversion.ch/amtm/amtm && sh amtm</code></pre>
   　   使用 SSH 　　 输入amtm　　  查看定时 　　重启路由测试  若提示卸载失败  则桥接移动网络热点安装  U盘若不能挂载  请更换U盘   不要期待有   脚本能实现

2、SS规则更新在路由软件中心管理界面先打开更新 再禁用定时 后面由定时任务接管


3、设定开机自动更新 定时任务 在jffs/scripts/post-mount里添加<pre><code class="language-html">#!/bin/sh
/jffs/scripts/set_crontab.sh &</code></pre>

4、下载 <pre><code class="language-html">mkdir -p /jffs/scripts/ && curl -o /jffs/scripts/Asuswrt-Merlin-Custom-Scripts.sh https://ghfast.top/https://raw.githubusercontent.com/klcb2010/Asuswrt-Merlin-Custom-Scripts/main/Asuswrt-Merlin-Custom-Scripts.sh && chmod 777 /jffs/scripts/Asuswrt-Merlin-Custom-Scripts.sh</code></pre>

5、运行<pre><code class="language-html">/jffs/scripts/Asuswrt-Merlin-Custom-Scripts.sh</code></pre>

6、规则更新前要SSH 输入替换规则  否则会提示未通过检验而导致更新失败 <pre><code class="language-html">sed -i 's|^URL_MAIN.*|URL_MAIN="https://raw.githubusercontent.com/qxzg/Actions/3.0/fancyss_rules"|' /koolshare/scripts/ss_rule_update.sh</code></pre>


7、开启华硕DDNS  从1002固件开启需要SSH手动开启 
脚本执行 在jffs/scripts/post-mount里添加  <pre> <code class="language-html">/jffs/scripts/set_territory.sh &</code></pre>


8 开启 webdav  用于向路由硬盘备份文档  同样在post-mount里调用   <pre> <code class="language-html">/jffs/scripts/rclone_webdav.sh &</code></pre>

前提 

刷 Asuswrt-Merlin 固件

插上 USB 已经分区的硬盘ext3和ntfs

开通外网访问：

网页后台开通 WAN 口 SSH（端口自定义默认22）

开通 asuscomm.com DDNS

开通 Let's Encrypt 免费证书（用于 HTTPS）

SSH 登录路由器，进入amtm 安装 Entware

通过amtm 安装 Entware 
<pre> <code class="language-html">reboot</code></pre>
<pre> <code class="language-html">opkg update</code></pre>
<pre> <code class="language-html">opkg install rclone</code></pre>
确认硬盘挂载路径 如 /tmp/mnt/SD/
<pre> <code class="language-html">ls /tmp/mnt/</code></pre>
<pre> <code class="language-html">df -h | grep mnt</code></pre>


创建独立自启脚本运行
<pre> <code class="language-html">/jffs/scripts/rclone_webdav.sh</code></pre>
重启后执行下列命令 看到 rclone 进程和日志
<pre> <code class="language-html">ps | grep [r]clone</code></pre>  

<pre> <code class="language-html">cat /tmp/rclone.log</code></pre> 


webdav地址是DDNS的地址:webdav端口

停止

<pre> <code class="language-html">killall rclone</code></pre>
