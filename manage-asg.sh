#!/bin/bash

# Check if auto-scaling-group-name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <auto-scaling-group-name>"
  exit 1
fi

AUTO_SCALING_GROUP_NAME=$1
AWS_REGION=${AWS_REGION:-eu-west-2} # Default region if not set

# Check the current desired capacity
DESIRED_CAPACITY=$(aws autoscaling describe-auto-scaling-groups \
  --region $AWS_REGION \
  --auto-scaling-group-names "$AUTO_SCALING_GROUP_NAME" \
  --query 'AutoScalingGroups[0].DesiredCapacity' --output text)

if [ "$DESIRED_CAPACITY" == "0" ]; then
  echo "The desired capacity for Auto Scaling Group '$AUTO_SCALING_GROUP_NAME' is 0."
  read -p "Do you want to start the instance? (yes/no): " RESPONSE
  if [ "$RESPONSE" == "yes" ]; then
    aws autoscaling set-desired-capacity \
      --region $AWS_REGION \
      --auto-scaling-group-name "$AUTO_SCALING_GROUP_NAME" \
      --desired-capacity 1
    echo "Desired capacity set to 1. Waiting for instance to launch..."
    
    # Wait for instance ID to appear
    TIMEOUT=60
    INTERVAL=5
    ELAPSED=0
    INSTANCE_ID=""
    while [ $ELAPSED -lt $TIMEOUT ]; do
      INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
        --region $AWS_REGION \
        --auto-scaling-group-names "$AUTO_SCALING_GROUP_NAME" \
        --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text 2>/dev/null)
      
      if [[ "$INSTANCE_ID" != "None" && -n "$INSTANCE_ID" ]]; then
        echo "Instance started successfully. Instance ID: $INSTANCE_ID"
        export INSTANCE_ID
        break
      fi
      sleep $INTERVAL
      ELAPSED=$((ELAPSED + INTERVAL))
    done
    
    if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" == "None" ]; then
      echo "Timed out waiting for instance to start. Please check manually."
      exit 1
    fi
  else
    echo "No changes made."
  fi
elif [ "$DESIRED_CAPACITY" == "1" ]; then
  echo "The desired capacity for Auto Scaling Group '$AUTO_SCALING_GROUP_NAME' is 1."
  
  # Fetch the InstanceId of the running instance
  INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$AUTO_SCALING_GROUP_NAME" \
    --region $AWS_REGION \
    --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)
  
  echo "The running instance in the Auto Scaling Group is InstanceId: $INSTANCE_ID"
  
  read -p "Do you want to stop the instance? This will terminate the running instance. (yes/no): " RESPONSE
  if [ "$RESPONSE" == "yes" ]; then
    aws autoscaling set-desired-capacity \
      --auto-scaling-group-name "$AUTO_SCALING_GROUP_NAME" \
      --region $AWS_REGION \
      --desired-capacity 0
    echo "Desired capacity set to 0. The running instance ($INSTANCE_ID) will be terminated."
  else
    echo "No changes made."
  fi
else
  echo "Unexpected desired capacity value: $DESIRED_CAPACITY."
  echo "Please check the Auto Scaling Group manually."
fi
