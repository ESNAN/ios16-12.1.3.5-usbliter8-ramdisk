#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

LOGDIR="logs"
mkdir -p "$LOGDIR"

IPROXY="${IPROXY:-iproxy}"
SSHPASS="${SSHPASS:-sshpass}"

pkill -f 'iproxy .*2222.*22' 2>/dev/null || true
nohup "$IPROXY" 2222 22 >>"$LOGDIR/iproxy-manual.log" 2>&1 &
echo $! > "$LOGDIR/iproxy.pid"
sleep 2

exec "$SSHPASS" -p alpine ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -p 2222 root@127.0.0.1
