#!/bin/bash

# ClickHouse服务地址和端口
CLICKHOUSE_HOST="clickhouse1"
CLICKHOUSE_PORT=9000

# 多用户信息：用户名和密码数组
declare -A USERS
USERS=(
  [user1]="password1"
  [user2]="password2"
  [admin_user]="admin_pass"
)

# 循环发送查询，每个用户执行几次简单查询，模拟请求
for user in "${!USERS[@]}"; do
  password=${USERS[$user]}
  
  echo "Starting queries for user: $user"

  for i in {1..5}; do
    clickhouse-client --host=$CLICKHOUSE_HOST --port=$CLICKHOUSE_PORT \
      --user=$user --password=$password \
      --query="SELECT count() FROM system.query_log WHERE event_time > now() - INTERVAL 1 HOUR;" &

    # 控制请求频率，可根据需要调整sleep时间
    sleep 1
  done
done

wait
echo "All queries sent."
