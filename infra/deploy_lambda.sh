#!/bin/bash
set -e

PROJECT_ROOT="$HOME/csv-processor"
LAYER_PATH="$PROJECT_ROOT/layer/lambda_layer.zip"
LAMBDA_PATH="$PROJECT_ROOT/lambda/lambda_function.zip"

# Package the Lambda function code
cd "$PROJECT_ROOT/lambda"
zip -r lambda_function.zip app.py

# Publish Lambda Layer (safe to run every time)
aws --endpoint-url=http://localhost:4566 lambda publish-layer-version \
    --layer-name CSVProcessorLayer \
    --zip-file fileb://$LAYER_PATH \
    --compatible-runtimes python3.8

# Delete existing Lambda (in case already exists)
aws --endpoint-url=http://localhost:4566 lambda delete-function \
    --function-name ProcessCSV || true

# Deploy Lambda with the new layer
aws --endpoint-url=http://localhost:4566 lambda create-function \
    --function-name ProcessCSV \
    --runtime python3.8 \
    --handler app.lambda_handler \
    --zip-file fileb://$LAMBDA_PATH \
    --layers arn:aws:lambda:us-east-1:000000000000:layer:CSVProcessorLayer:1 \
    --role arn:aws:iam::000000000000:role/lambda-role


