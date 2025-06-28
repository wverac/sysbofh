#!/usr/bin/env bash

# Tailscale management script for macOS
# Usage: ./tailscale-macos.sh [start|stop|status|up|down|restart]

TAILSCALE_DIR="$HOME/.local/share/tailscale"
SOCKET_PATH="$TAILSCALE_DIR/tailscaled.sock"
PID_FILE="$TAILSCALE_DIR/tailscaled.pid"
LOG_FILE="$TAILSCALE_DIR/tailscaled.log"

mkdir -p "$TAILSCALE_DIR"

is_running() {
  if [[ -f "$PID_FILE" ]]; then
    local pid=$(cat "$PID_FILE")
    if ps -p "$pid" >/dev/null 2>&1; then
      return 0
    else
      # Clean up stale PID file
      rm -f "$PID_FILE"
      return 1
    fi
  fi
  return 1
}

start_daemon() {
  if is_running; then
    echo "tailscaled is already running (PID: $(cat $PID_FILE))"
    return 0
  fi

  echo "Starting tailscaled..."
  rm -f "$SOCKET_PATH"

  nohup tailscaled \
    --statedir="$TAILSCALE_DIR" \
    --socket="$SOCKET_PATH" \
    --tun=userspace-networking \
    >"$LOG_FILE" 2>&1 &

  local pid=$!
  echo $pid >"$PID_FILE"

  sleep 2
  if is_running; then
    echo "tailscaled started successfully (PID: $pid)"
    return 0
  else
    echo "Failed to start tailscaled. Check log: $LOG_FILE"
    return 1
  fi
}

stop_daemon() {
  if ! is_running; then
    echo "tailscaled is not running"
    return 0
  fi

  local pid=$(cat "$PID_FILE")
  echo "Stopping tailscaled (PID: $pid)..."

  kill "$pid"

  local count=0
  while ps -p "$pid" >/dev/null 2>&1 && [[ $count -lt 10 ]]; do
    sleep 1
    ((count++))
  done

  if ps -p "$pid" >/dev/null 2>&1; then
    echo "Force killing tailscaled..."
    kill -9 "$pid"
  fi

  # Clean up
  rm -f "$PID_FILE" "$SOCKET_PATH"
  echo "tailscaled stopped"
}

show_status() {
  if is_running; then
    echo "tailscaled is running (PID: $(cat $PID_FILE))"
    echo "Socket: $SOCKET_PATH"
    echo "Log: $LOG_FILE"

    # Show tailscale status if daemon is running
    if [[ -S "$SOCKET_PATH" ]]; then
      echo ""
      echo "Tailscale status:"
      tailscale --socket="$SOCKET_PATH" status 2>/dev/null || echo "Not connected to Tailscale network"
    fi
  else
    echo "tailscaled is not running"
  fi
}

tailscale_up() {
  if ! is_running; then
    echo "Starting tailscaled first..."
    start_daemon || return 1
  fi

  echo "Connecting to Tailscale..."
  tailscale --socket="$SOCKET_PATH" up --accept-routes --ssh
}

tailscale_down() {
  if ! is_running; then
    echo "tailscaled is not running"
    return 1
  fi

  echo "Disconnecting from Tailscale..."
  tailscale --socket="$SOCKET_PATH" down
}

restart_daemon() {
  stop_daemon
  sleep 1
  start_daemon
}

case "${1:-status}" in
start)
  start_daemon
  ;;
stop)
  stop_daemon
  ;;
restart)
  restart_daemon
  ;;
status)
  show_status
  ;;
up)
  tailscale_up
  ;;
down)
  tailscale_down
  ;;
logs)
  if [[ -f "$LOG_FILE" ]]; then
    tail -f "$LOG_FILE"
  else
    echo "No log file found at $LOG_FILE"
  fi
  ;;
*)
  echo "Usage: $0 [start|stop|restart|status|up|down|logs]"
  echo ""
  echo "Commands:"
  echo "  start    - Start tailscaled daemon"
  echo "  stop     - Stop tailscaled daemon"
  echo "  restart  - Restart tailscaled daemon"
  echo "  status   - Show daemon and connection status"
  echo "  up       - Start daemon and connect to Tailscale"
  echo "  down     - Disconnect from Tailscale"
  echo "  logs     - Show tailscaled logs"
  exit 1
  ;;
esac
