#!/bin/sh
MODDIR=$(cd $(dirname $0)/..; pwd)
CONF_FILE="$MODDIR/config/ech.conf"
LOG_FILE="$MODDIR/ech-workers.log"
BIN_FILE="$MODDIR/bin/ech-workers"

# 读取配置
read_config() {
  while IFS='=' read -r key value; do
    export "$key"="$value"
  done < "$CONF_FILE"
}

# 保存配置（UI 调用）
save_config() {
  cat > "$CONF_FILE" << EOF
server_addr=$1
local_port=$2
doh_server=$3
ech_domain=$4
preferred_ip=$5
auth_token=$6
routing_mode=$7
enabled=$8
EOF
}

# 启动代理
start_ech() {
  pkill -f "$BIN_FILE" 2>/dev/null
  ARGS="-f $server_addr -l 0.0.0.0:$local_port -dns $doh_server -ech $ech_domain"
  [ -n "$preferred_ip" ] && ARGS="$ARGS -ip $preferred_ip"
  [ -n "$auth_token" ] && ARGS="$ARGS -token $auth_token"
  ARGS="$ARGS -routing $routing_mode"
  
  # 启动并返回结果
  if nohup "$BIN_FILE" $ARGS > "$LOG_FILE" 2>&1 &; then
    save_config "$server_addr" "$local_port" "$doh_server" "$ech_domain" "$preferred_ip" "$auth_token" "$routing_mode" "true"
    echo "success"
  else
    echo "fail: $(cat $LOG_FILE | tail -1)"
  fi
}

# 停止代理
stop_ech() {
  pkill -f "$BIN_FILE" 2>/dev/null
  save_config "$server_addr" "$local_port" "$doh_server" "$ech_domain" "$preferred_ip" "$auth_token" "$routing_mode" "false"
  echo "success"
}

# 查看状态
check_status() {
  if pgrep -f "$BIN_FILE" > /dev/null; then
    echo "running"
  else
    echo "stopped"
  fi
}

# 读取日志
get_log() {
  cat "$LOG_FILE" 2>/dev/null | tail -20 # 只显示最后20行
}

# 主逻辑
case "$1" in
  save)
    save_config "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
    echo "saved"
    ;;
  start)
    read_config
    start_ech
    ;;
  stop)
    read_config
    stop_ech
    ;;
  status)
    check_status
    ;;
  log)
    get_log
    ;;
  get_config)
    read_config
    echo "$server_addr|$local_port|$doh_server|$ech_domain|$preferred_ip|$auth_token|$routing_mode|$enabled"
    ;;
  *)
    echo "usage: $0 save|start|stop|status|log|get_config"
    exit 1
    ;;
esac
