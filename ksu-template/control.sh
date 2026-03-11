#!/bin/sh
MODPATH="/data/adb/modules/ech-workers-ksu"
BIN="$MODPATH/bin/ech-workers"
CONF="$MODPATH/etc/config.txt"
PIDFILE="$MODPATH/run/ech-workers.pid"
LOG="$MODPATH/run/ech-workers.log"

# 初始化目录/文件
mkdir -p "$MODPATH/etc" "$MODPATH/run"
touch "$CONF" "$PIDFILE" "$LOG"

# 读取配置
load_config() {
  if [ -f "$CONF" ]; then
    while IFS='=' read -r k v; do
      case "$k" in
        server_addr|local_port|doh_server|ech_domain|preferred_ip|auth_token|routing_mode)
          eval "$k=\"$v\""
          ;;
      esac
    done < "$CONF"
  fi
}

# 保存配置
save_config() {
  cat > "$CONF" << EOF
server_addr=$1
local_port=$2
doh_server=$3
ech_domain=$4
preferred_ip=$5
auth_token=$6
routing_mode=$7
EOF
}

# 启动代理（后台运行，写PID）
start() {
  load_config
  stop  # 先停止旧进程

  # 构建启动参数
  ARGS="-f $server_addr -l 0.0.0.0:$local_port -dns $doh_server -ech $ech_domain"
  [ -n "$preferred_ip" ] && ARGS="$ARGS -ip $preferred_ip"
  [ -n "$auth_token" ] && ARGS="$ARGS -token $auth_token"
  ARGS="$ARGS -routing $routing_mode"

  # 后台启动（和 netproxy 一致）
  nohup "$BIN" $ARGS > "$LOG" 2>&1 &
  echo $! > "$PIDFILE"
  echo "started"
}

# 停止代理（读PID杀进程）
stop() {
  if [ -s "$PIDFILE" ]; then
    kill -9 $(cat "$PIDFILE") 2>/dev/null
    rm -f "$PIDFILE"
  fi
  echo "stopped"
}

# 检测状态
status() {
  if [ -s "$PIDFILE" ] && ps -p $(cat "$PIDFILE") >/dev/null 2>&1; then
    echo "running"
  else
    echo "stopped"
  fi
}

# 主逻辑
case "$1" in
  save)
    save_config "$2" "$3" "$4" "$5" "$6" "$7" "$8"
    echo "saved"
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  log)
    tail -20 "$LOG"
    ;;
  get_config)
    load_config
    echo "$server_addr|$local_port|$doh_server|$ech_domain|$preferred_ip|$auth_token|$routing_mode"
    ;;
  *)
    echo "usage: $0 save|start|stop|status|log|get_config"
    exit 1
    ;;
esac
