#!/bin/bash

OUTPUT_DIR="/home/clickhouse-cluster/node_exporter/textfile_collector"
OUTPUT_FILE="$OUTPUT_DIR/clickhouse_user_qps.prom"

mkdir -p "$OUTPUT_DIR"

# Prometheus指标头
echo "# HELP clickhouse_user_qps Query Per Second (QPS) per user in the last N minutes" > "$OUTPUT_FILE"
echo "# TYPE clickhouse_user_qps gauge" >> "$OUTPUT_FILE"

# 集群节点列表
NODES=(clickhouse1 clickhouse2)

for node in "${NODES[@]}"; do
    # 生成1-10的随机分钟区间
    interval=$(( RANDOM % 10 + 1 ))

    QUERY="
    SELECT
        user,
        count() AS qps
    FROM system.query_log
    WHERE event_time > now() - INTERVAL $interval MINUTE
    GROUP BY user
    "

    # 执行查询
    docker exec "$node" clickhouse-client --user=default --password='123456' --format=TSV --query="$QUERY" | \
    while read user qps; do
        if [[ -n "$user" ]]; then
            # 把节点和时间间隔加为标签，方便区分
            echo "clickhouse_user_qps{node=\"$node\",user=\"$user\",interval=\"${interval}m\"} $qps" >> "$OUTPUT_FILE"
        fi
    done
done
