   　      　      　      　      　      　      　      　      　 仅适合梅林原版及改版　　用于修正原版及改版的定时任务缺陷与WiFi断流

1、定时任务前提条件
   　   安装 <pre><code class="language-html">/usr/sbin/curl -Os https://diversion.ch/amtm/amtm && sh amtm</code></pre>
   　   使用 SSH 　　 输入amtm　　  查看定时 　　重启路由测试  若提示卸载失败  则桥接移动网络热点安装  U盘若不能挂载  请更换U盘   不要期待有   脚本能实现

2、SS更新管理先打开要更新的内容  再禁用定时


3、设定开机自动更新 定时任务 在jffs/scripts/post-mount里添加<pre><code class="language-html">#!/bin/sh
/jffs/scripts/set_crontab.sh &</code></pre>

4、下载 <pre><code class="language-html">mkdir -p /jffs/scripts/ && curl -o /jffs/scripts/restart_wan-cron-ss.sh https://ghfast.top/https://raw.githubusercontent.com/klcb2010/restart_wan-cron-ss-mod/main/restart_wan-cron-ss.sh && chmod 777 /jffs/scripts/restart_wan-cron-ss.sh</code></pre>

5、运行<pre><code class="language-html">/jffs/scripts/restart_wan-cron-ss.sh</code></pre>

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
<pre> <code class="language-html">/jffs/scripts/rclone_webdav.sh</code></pre>与<pre> <code class="language-html">ddns_check.sh</code></pre>确保DDNS不掉，需把ddns_check.sh加到定时任务里去
重启后执行下列命令 看到 rclone 进程和日志
<pre> <code class="language-html">ps | grep rclone</code></pre>  

<pre> <code class="language-html">cat /tmp/rclone.log</code></pre> 


停止

<pre> <code class="language-html">killall rclone</code></pre>
