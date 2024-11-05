#!/bin/bash
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
while true; do
    memory_usage=$(free -m | awk '/^Mem:/ { print $3/$2 * 100 }')
    aws cloudwatch put-metric-data --metric-name MemoryUsage --namespace Custom --value $memory_usage --dimensions InstanceId=$instance_id
    sleep 60
done &