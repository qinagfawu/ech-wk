MODDIR=${0%/*}

# 停止代理进程
if [ -f "$MODDIR/ech-workers.pid" ]; then
  kill $(cat "$MODDIR/ech-workers.pid") 2>/dev/null
  rm -f "$MODDIR/ech-workers.pid"
fi

# 清理日志和配置
rm -f "$MODDIR/ech-workers.log"
ksud module config clear  # 清空模块配置

# 提示卸载完成
ui_print "ECH Workers KSU 模块已卸载！"
