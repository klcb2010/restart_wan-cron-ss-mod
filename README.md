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


开启华硕DDNS <pre><code class="language-html">nvram set territory_code=US/01</code></pre>
