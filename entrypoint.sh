#!/bin/bash

# 1. 启动 Nginx
# 使用 -g 'daemon off;' 让 nginx 在前台运行以便监控，或者用 & 配合 PID
nginx -g 'daemon off;' &
NGINX_PID=$!

# 2. 启动 Xray
/usr/local/bin/xray -config /etc/xray/config.json &
XRAY_PID=$!

echo "Processes started: Nginx($NGINX_PID), Xray($XRAY_PID)"

# 3. 循环检查进程状态
while sleep 10; do
  kill -0 $NGINX_PID 2>/dev/null
  NGINX_STATUS=$?
  
  kill -0 $XRAY_PID 2>/dev/null
  XRAY_STATUS=$?

  if [ $NGINX_STATUS -ne 0 ] || [ $XRAY_STATUS -ne 0 ]; then
    echo "Detection: One of the processes has exited."
    echo "Nginx status: $NGINX_STATUS, Xray status: $XRAY_STATUS"
    echo "Shutting down container to trigger Fly.io restart..."
    exit 1
  fi
done
