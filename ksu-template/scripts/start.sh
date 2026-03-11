#!/bin/sh
MODDIR=$(cd $(dirname $0)/..; pwd)

# 启停控制逻辑
case "$1" in
  start)
    # 停止旧进程
    if [ -f "$MODDIR/ech-workers.pid" ]; then
      kill $(cat "$MODDIR/ech-workers.pid") 2>/dev/null
      rm -f "$MODDIR/ech-workers.pid"
    fi
    # 读取配置并启动
    SERVER_ADDR=$(ksud module config get server_addr)
    LOCAL_PORT=$(ksud module config get local_port)
    DOH_SERVER=$(ksud module config get doh_server)
    ECH_DOMAIN=$(ksud module config get ech_domain)
    PREFERRED_IP=$(ksud module config get preferred_ip)
    AUTH_TOKEN=$(ksud module config get auth_token)
    ROUTING_MODE=$(ksud module config get routing_mode)
    
    ARGS="-f $SERVER_ADDR -l 0.0.0.0:$LOCAL_PORT -dns $DOH_SERVER -ech $ECH_DOMAIN"
    [ -n "$PREFERRED_IP" ] && ARGS="$ARGS -ip $PREFERRED_IP"
    [ -n "$AUTH_TOKEN" ] && ARGS="$ARGS -token $AUTH_TOKEN"
    ARGS="$ARGS -routing $ROUTING_MODE"
    
    nohup "$MODDIR/bin/ech-workers" $ARGS > "$MODDIR/ech-workers.log" 2>&1 &
    echo $! > "$MODDIR/ech-workers.pid"
    ksud module config set enabled "true"
    echo "started"
    ;;
  stop)
    if [ -f "$MODDIR/ech-workers.pid" ]; then
      kill $(cat "$MODDIR/ech-workers.pid") 2>/dev/null
      rm -f "$MODDIR/ech-workers.pid"
    fi
    ksud module config set enabled "false"
    echo "stopped"
    ;;
  status)
    if [ -f "$MODDIR/ech-workers.pid" ] && ps -p $(cat "$MODDIR/ech-workers.pid") > /dev/null 2>&1; then
      echo "running"
    else
      echo "stopped"
    fi
    ;;
  *)
    echo "用法: $0 start|stop|status"
    exit 1
    ;;
esac
