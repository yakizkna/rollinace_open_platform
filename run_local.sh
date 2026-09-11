#!/usr/bin/env bash
# rollinace_open_platform 本地预览启停脚本（纯静态站点：无构建、无框架、无依赖）
#
# 用法：
#   ./run_local.sh start     后台启动本地预览（默认 http://localhost:8095，PORT=xxxx 覆盖）
#   ./run_local.sh stop      停止
#   ./run_local.sh restart   重启
#   ./run_local.sh status    查看运行状态 + 健康检查
#
# 说明：
#   - 站点是纯静态（index.html + css），用 python3 -m http.server 起本地服务即可，
#     不需要 npm / npx / 任何构建步骤（README 的「本地预览」也写明了等价命令）。
#   - 只监听 127.0.0.1（本机预览，不外露）。
#   - pid 与日志写在 .run/（已 .gitignore，不入库）。
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PORT="${PORT:-8095}"
RUN_DIR=".run"
PID_FILE="$RUN_DIR/run_local.pid"
LOG_FILE="$RUN_DIR/run_local.log"

mkdir -p "$RUN_DIR"

get_pid() {
  if [ -f "$PID_FILE" ]; then cat "$PID_FILE"; fi
}

is_running() {
  local pid; pid="$(get_pid)"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

do_start() {
  if is_running; then
    echo "已在运行：http://localhost:${PORT}/ （pid $(get_pid)）"
    return 0
  fi
  echo "启动本地预览：http://localhost:${PORT}/"
  nohup python3 -m http.server "$PORT" --bind 127.0.0.1 >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  sleep 1
  if is_running; then
    echo "已启动（pid $(get_pid)；日志：${LOG_FILE}）"
  else
    echo "启动失败，请查看日志：${LOG_FILE}" >&2
    rm -f "$PID_FILE"
    return 1
  fi
}

do_stop() {
  if ! is_running; then
    echo "未在运行"
    rm -f "$PID_FILE"
    return 0
  fi
  local pid; pid="$(get_pid)"
  kill "$pid" 2>/dev/null || true
  # 优雅退出最多等 5s，仍未退出则强杀
  for _ in 1 2 3 4 5; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 1
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true
  fi
  rm -f "$PID_FILE"
  echo "已停止"
}

do_status() {
  if is_running; then
    echo "运行中（pid $(get_pid)）→ http://localhost:${PORT}/"
    curl -s -o /dev/null --max-time 3 "http://127.0.0.1:${PORT}/" \
      && echo "健康检查：OK" || echo "健康检查：无响应"
  else
    echo "未运行"
  fi
}

case "${1:-start}" in
  start)   do_start ;;
  stop)    do_stop ;;
  restart) do_stop; do_start ;;
  status)  do_status ;;
  -h)      sed -n '2,14p' "$0"; exit 0 ;;
  *)       echo "用法: $0 {start|stop|restart|status}" >&2; exit 1 ;;
esac
