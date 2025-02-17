#!/bin/bash

# Default AWS region
AWS_REGION="${AWS_REGION:-eu-west-2}"

# Check if an instance ID is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <INSTANCE_ID>"
    exit 1
fi

INSTANCE_ID="$1"
LOCAL_PORT="9999"
REMOTE_PORT="8000"

echo "Starting AWS SSM port forwarding session..."
echo "Instance: $INSTANCE_ID | Region: $AWS_REGION | Local Port: $LOCAL_PORT | Remote Port: $REMOTE_PORT"

aws ssm start-session --target "$INSTANCE_ID" \
    --document-name AWS-StartPortForwardingSession \
    --parameters "{\"portNumber\":[\"$REMOTE_PORT\"],\"localPortNumber\":[\"$LOCAL_PORT\"]}" \
    --region "$AWS_REGION"
