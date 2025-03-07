#!/bin/bash
set -e


echo "Checking for Lambda function ProcessCSV"

until aws --endpoint-url=http://localhost:4566 lambda get-function \
    --function-name ProcessCSV > /dev/null 2>&1; do
    echo "Lambda not found. Retrying in 5 seconds..."
    sleep 5
done

echo "Lambda found. Proceeding to configure S3 event."

# Correctly apply the event notification configuration
aws --endpoint-url=http://localhost:4566 s3api put-bucket-notification-configuration \
    --bucket uplyft-csv-bucket \
    --notification-configuration file://$(dirname "$0")/s3_event_config.json

