param (
    [string]$AutoScalingGroupName
)

if (-not $AutoScalingGroupName) {
    Write-Host "Usage: .\manage-autoscaling.ps1 -AutoScalingGroupName <Auto-Scaling-Group-Name>"
    exit 1
}

$AWS_REGION = $env:AWS_REGION -or "eu-west-2"

# Get the current desired capacity
$DesiredCapacity = aws autoscaling describe-auto-scaling-groups `
    --region $AWS_REGION `
    --auto-scaling-group-names $AutoScalingGroupName `
    --query 'AutoScalingGroups[0].DesiredCapacity' `
    --output text

if ($DesiredCapacity -eq "0") {
    Write-Host "The desired capacity for Auto Scaling Group '$AutoScalingGroupName' is 0."
    $Response = Read-Host "Do you want to start the instance? (yes/no)"

    if ($Response -eq "yes") {
        aws autoscaling set-desired-capacity `
            --region $AWS_REGION `
            --auto-scaling-group-name $AutoScalingGroupName `
            --desired-capacity 1
        Write-Host "Desired capacity set to 1. Waiting for instance to launch..."

        # Wait for instance to launch
        $Timeout = 60
        $Interval = 5
        $Elapsed = 0
        $InstanceId = ""

        while ($Elapsed -lt $Timeout) {
            $InstanceId = aws autoscaling describe-auto-scaling-groups `
                --region $AWS_REGION `
                --auto-scaling-group-names $AutoScalingGroupName `
                --query 'AutoScalingGroups[0].Instances[0].InstanceId' `
                --output text 2>$null

            if ($InstanceId -and $InstanceId -ne "None") {
                Write-Host "Instance started successfully. Instance ID: $InstanceId"
                $env:INSTANCE_ID = $InstanceId
                break
            }
            
            Start-Sleep -Seconds $Interval
            $Elapsed += $Interval
        }

        if (-not $InstanceId -or $InstanceId -eq "None") {
            Write-Host "Timed out waiting for instance to start. Please check manually."
            exit 1
        }
    } else {
        Write-Host "No changes made."
    }
}
elseif ($DesiredCapacity -eq "1") {
    Write-Host "The desired capacity for Auto Scaling Group '$AutoScalingGroupName' is 1."

    # Fetch the running instance ID
    $InstanceId = aws autoscaling describe-auto-scaling-groups `
        --region $AWS_REGION `
        --auto-scaling-group-names $AutoScalingGroupName `
        --query 'AutoScalingGroups[0].Instances[0].InstanceId' `
        --output text

    Write-Host "The running instance in the Auto Scaling Group is Instance ID: $InstanceId"
    $Response = Read-Host "Do you want to stop the instance? This will terminate the running instance. (yes/no)"

    if ($Response -eq "yes") {
        aws autoscaling set-desired-capacity `
            --region $AWS_REGION `
            --auto-scaling-group-name $AutoScalingGroupName `
            --desired-capacity 0
        Write-Host "Desired capacity set to 0. The running instance ($InstanceId) will be terminated."
    } else {
        Write-Host "No changes made."
    }
}
else {
    Write-Host "Unexpected desired capacity value: $DesiredCapacity."
    Write-Host "Please check the Auto Scaling Group manually."
}
