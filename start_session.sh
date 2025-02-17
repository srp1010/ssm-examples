#!/bin/bash

# Check if an instance ID is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <INSTANCE_ID>"
    exit 1
fi

INSTANCE_ID="$1"
AWS_REGION="eu-west-2"

echo "Starting AWS SSM session for instance: $INSTANCE_ID in region: $AWS_REGION..."
aws ssm start-session --target "$INSTANCE_ID" --region "$AWS_REGION"
