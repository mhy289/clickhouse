#!/bin/bash

# ClickHouse�����ַ�Ͷ˿�
CLICKHOUSE_HOST="clickhouse1"
CLICKHOUSE_PORT=9000

# ���û���Ϣ���û�������������
declare -A USERS
USERS=(
  [user1]="password1"
  [user2]="password2"
  [admin_user]="admin_pass"
)

# ѭ�����Ͳ�ѯ��ÿ���û�ִ�м��μ򵥲�ѯ��ģ������
for user in "${!USERS[@]}"; do
  password=${USERS[$user]}
  
  echo "Starting queries for user: $user"

  for i in {1..5}; do
    clickhouse-client --host=$CLICKHOUSE_HOST --port=$CLICKHOUSE_PORT \
      --user=$user --password=$password \
      --query="SELECT count() FROM system.query_log WHERE event_time > now() - INTERVAL 1 HOUR;" &

    # ��������Ƶ�ʣ��ɸ�����Ҫ����sleepʱ��
    sleep 1
  done
done

wait
echo "All queries sent."
