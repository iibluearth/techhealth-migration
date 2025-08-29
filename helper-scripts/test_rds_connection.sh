#!/bin/bash

# RDS Connection Test Script
# Run this on your EC2 instance

echo "Testing RDS Connection using Secrets Manager credentials..."

# Get the secret ARN and RDS endpoint from AWS (more secure approach)
SECRET_ARN=$(aws cloudformation describe-stacks --stack-name YourStackName --query 'Stacks[0].Outputs[?OutputKey==`RDSSecretArn`].OutputValue' --output text)
RDS_ENDPOINT=$(aws cloudformation describe-stacks --stack-name YourStackName --query 'Stacks[0].Outputs[?OutputKey==`RDSEndpoint`].OutputValue' --output text)

echo "Retrieving credentials from Secrets Manager..."

# Retrieve the secret value
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text)

if [ $? -ne 0 ]; then
    echo "Failed to retrieve secret from Secrets Manager"
    exit 1
fi

# Parse credentials using jq
USERNAME=$(echo "$SECRET_JSON" | jq -r .username)
PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)
DB_NAME=$(echo "$SECRET_JSON" | jq -r .dbname)

echo "Retrieved credentials successfully"
echo "Username: $USERNAME"
echo "Database: $DB_NAME"
echo "Endpoint: $RDS_ENDPOINT"


# Test the connection
echo "Testing MySQL connection..."

mysql -h "$RDS_ENDPOINT" -u "$USERNAME" -p"$PASSWORD" -e "SELECT 'Connection successful!' as Status, VERSION() as MySQL_Version;"

if [ $? -eq 0 ]; then
    echo "✅ RDS connection test PASSED!"
else
    echo "❌ RDS connection test FAILED!"
    exit 1
fi

# Optional: Test creating a database
echo "Testing database operations..."
mysql -h "$RDS_ENDPOINT" -u "$USERNAME" -p"$PASSWORD" -e "
    CREATE DATABASE IF NOT EXISTS test_db;
    USE test_db;
    CREATE TABLE IF NOT EXISTS test_table (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255));
    INSERT INTO test_table (message) VALUES ('Connection test successful');
    SELECT * FROM test_table;
    DROP TABLE test_table;
    DROP DATABASE test_db;
"

if [ $? -eq 0 ]; then
    echo "✅ Database operations test PASSED!"
else
    echo "❌ Database operations test FAILED!"
fi