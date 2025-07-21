#!/bin/bash

USERS=(user1 user2 user3 user4 user5 user6 user7 user8 user9 user10)
PASSWORD="123456"
NODES=(clickhouse1 clickhouse2)
LOG_FILE="/var/log/simulate_users.log"

echo "$(date) - simulate_users.sh started" >> "$LOG_FILE"

while true; do
  for i in {1..50}; do
    user=${USERS[$RANDOM % ${#USERS[@]}]}
    node=${NODES[$RANDOM % ${#NODES[@]}]}

    echo "$(date) - Sending query as $user to $node" >> "$LOG_FILE"

    docker exec "$node" clickhouse-client \
      --user="$user" --password="$PASSWORD" \
      --query="SELECT count() FROM numbers(10000000)" >> "$LOG_FILE" 2>&1 &

    sleep 0.1
  done
  wait
done
