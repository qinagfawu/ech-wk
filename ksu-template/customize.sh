SKIPUNZIP=1

# 解压模块
unzip -o "$ZIPFILE" -d "$MODPATH" >&2

# 创建核心目录（配置/日志/二进制）
mkdir -p "$MODPATH/bin"
mkdir -p "$MODPATH/scripts"
mkdir -p "$MODPATH/webroot"
mkdir -p "$MODPATH/config"

# 初始化配置文件（解决配置丢失）
touch "$MODPATH/config/ech.conf"
cat > "$MODPATH/config/ech.conf" << EOF
server_addr=your-worker.workers.dev:443
local_port=30000
doh_server=dns.alidns.com/dns-query
ech_domain=cloudflare-ech.com
preferred_ip=
auth_token=
routing_mode=global
enabled=false
EOF

# 创建日志文件并赋权（解决无日志）
touch "$MODPATH/ech-workers.log"
chmod 777 "$MODPATH/ech-workers.log"

# 强制设置所有权限（解决启动无反应）
chmod -R 755 "$MODPATH/bin"
chmod -R 755 "$MODPATH/scripts"
chmod 755 "$MODPATH/service.sh"
chmod 755 "$MODPATH/uninstall.sh"
chmod 666 "$MODPATH/config/ech.conf" # 配置文件可读写

# 提示安装完成
ui_print "✅ ECH Workers KSU 模块安装完成！"
ui_print "👉 打开 KernelSU → 模块 → 点击本模块的 WebUI 配置使用"
