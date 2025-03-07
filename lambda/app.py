import json
import boto3
import pandas as pd
from io import StringIO
from datetime import datetime

s3_client = boto3.client('s3', endpoint_url='http://localhost:4566')
dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:4566')
table = dynamodb.Table('CSVMetadata')

def lambda_handler(event, context):
    try:
        print(f"Received event: {json.dumps(event)}")  # Add debug log

        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        print(f"Processing file: {key} from bucket: {bucket}")

        response = s3_client.get_object(Bucket=bucket, Key=key)
        file_content = response['Body'].read().decode('utf-8')

        df = pd.read_csv(StringIO(file_content))

        metadata = {
            'filename': key,
            'upload_timestamp': datetime.now().isoformat(),
            'file_size_bytes': response['ContentLength'],
            'row_count': len(df),
            'column_count': len(df.columns),
            'column_names': df.columns.tolist()
        }

        print(f"Inserting metadata: {json.dumps(metadata)}")

        table.put_item(Item=metadata)

        return {'statusCode': 200, 'body': json.dumps(metadata)}

    except Exception as e:
        print(f"Error processing file: {e}")
        return {'statusCode': 500, 'body': str(e)}
