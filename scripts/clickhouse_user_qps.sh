#!/bin/bash

OUTPUT_DIR="/home/clickhouse-cluster/node_exporter/textfile_collector"
OUTPUT_FILE="$OUTPUT_DIR/clickhouse_user_qps.prom"
PASSWORD="123456"
NODES=(clickhouse1 clickhouse2)
LOG_FILE="/var/log/clickhouse_user_qps.log"

mkdir -p "$OUTPUT_DIR"

while true; do
  echo "$(date) - Start collecting QPS" >> "$LOG_FILE"

  TMP_FILE=$(mktemp)
  echo "# HELP clickhouse_user_qps Query Per Second (QPS) per user in the last 1 minute" > "$TMP_FILE"
  echo "# TYPE clickhouse_user_qps gauge" >> "$TMP_FILE"

  for NODE in "${NODES[@]}"; do
    echo "$(date) - Querying node: $NODE" >> "$LOG_FILE"
    result=$(docker exec "$NODE" clickhouse-client --user=default --password="$PASSWORD" --format=TSV --query="
      SELECT user, count() AS qps FROM system.query_log
      WHERE event_time > now() - INTERVAL 90 SECOND
      GROUP BY user
    " 2>>"$LOG_FILE")

    if [[ -z "$result" ]]; then
      echo "$(date) - Warning: No result from $NODE" >> "$LOG_FILE"
    fi

    while IFS=$'\t' read -r user qps; do
      if [[ -n "$user" ]]; then
        echo "clickhouse_user_qps{user=\"$user\",node=\"$NODE\"} $qps" >> "$TMP_FILE"
        echo "$(date) - Found user=$user with qps=$qps on $NODE" >> "$LOG_FILE"
      fi
    done <<< "$result"
  done

  mv "$TMP_FILE" "$OUTPUT_FILE"
  echo "$(date) - Collection finished, output to $OUTPUT_FILE" >> "$LOG_FILE"

  sleep 60
done
