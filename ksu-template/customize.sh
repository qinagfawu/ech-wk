SKIPUNZIP=1

# 解压模块文件到 MODPATH
unzip -o "$ZIPFILE" -d "$MODPATH" >&2

# 创建必要目录
mkdir -p "$MODPATH/bin"
mkdir -p "$MODPATH/scripts"
mkdir -p "$MODPATH/webroot"

# 设置权限（核心）
set_perm_recursive "$MODPATH/bin" 0 0 0755 0755
set_perm_recursive "$MODPATH/scripts" 0 0 0755 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755

# 初始化默认配置（KSU 内置配置系统）
ksud module config set server_addr "your-worker.workers.dev:443"
ksud module config set local_port "30000"
ksud module config set doh_server "dns.alidns.com/dns-query"
ksud module config set ech_domain "cloudflare-ech.com"
ksud module config set preferred_ip ""
ksud module config set auth_token ""
ksud module config set routing_mode "global"
ksud module config set enabled "false"

# 提示安装完成
ui_print "ECH Workers KSU 模块安装完成！"
ui_print "请在 KernelSU WebUI 中配置服务器信息后使用。"
