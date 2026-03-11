SKIPUNZIP=1
unzip -o "$ZIPFILE" -d "$MODPATH" >&2

# 初始化 netproxy 标准目录
mkdir -p "$MODPATH/etc" "$MODPATH/run"
touch "$MODPATH/etc/config.txt" "$MODPATH/run/ech-workers.pid" "$MODPATH/run/ech-workers.log"

# 强制设置权限（解决安卓权限问题）
chmod -R 755 "$MODPATH/bin"
chmod -R 755 "$MODPATH/scripts"
chmod 644 "$MODPATH/etc/config.txt"
chmod 644 "$MODPATH/run/*"
chmod 755 "$MODPATH/service.sh"
chmod 755 "$MODPATH/control.sh"

ui_print "✅ ECH Workers 模块安装完成（兼容 netproxy 规范）"
ui_print "👉 打开 KernelSU → 模块 → WebUI 配置使用"
