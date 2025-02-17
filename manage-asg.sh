#!/bin/bash

AWS_REGION="eu-west-2"  # Set to your desired region

# Check if auto-scaling-group-name is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <auto-scaling-group-name>"
  exit 1
fi

AUTO_SCALING_GROUP_NAME=$1

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
    echo "Desired capacity set to 1."
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
