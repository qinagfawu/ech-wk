MODDIR=${0%/*}

# 从 KSU 配置读取参数
SERVER_ADDR=$(ksud module config get server_addr)
LOCAL_PORT=$(ksud module config get local_port)
DOH_SERVER=$(ksud module config get doh_server)
ECH_DOMAIN=$(ksud module config get ech_domain)
PREFERRED_IP=$(ksud module config get preferred_ip)
AUTH_TOKEN=$(ksud module config get auth_token)
ROUTING_MODE=$(ksud module config get routing_mode)
ENABLED=$(ksud module config get enabled)

# 如果未启用，直接退出
if [ "$ENABLED" != "true" ]; then
  exit 0
fi

# 停止旧进程（防止重复启动）
if [ -f "$MODDIR/ech-workers.pid" ]; then
  kill $(cat "$MODDIR/ech-workers.pid") 2>/dev/null
  rm -f "$MODDIR/ech-workers.pid"
fi

# 构建启动参数
ARGS="-f $SERVER_ADDR -l 0.0.0.0:$LOCAL_PORT -dns $DOH_SERVER -ech $ECH_DOMAIN"
[ -n "$PREFERRED_IP" ] && ARGS="$ARGS -ip $PREFERRED_IP"
[ -n "$AUTH_TOKEN" ] && ARGS="$ARGS -token $AUTH_TOKEN"
ARGS="$ARGS -routing $ROUTING_MODE"

# 后台启动代理（输出日志）
nohup "$MODDIR/bin/ech-workers" $ARGS > "$MODDIR/ech-workers.log" 2>&1 &
echo $! > "$MODDIR/ech-workers.pid"
