param (
    [string]$InstanceId
)

if (-not $InstanceId) {
    Write-Host "Usage: .\start-port-forwarding.ps1 -InstanceId <INSTANCE_ID>"
    exit 1
}

$AWS_REGION = "eu-west-2"
$LOCAL_PORT = "9999"
$REMOTE_PORT = "8000"

Write-Host "Starting AWS SSM port forwarding session..."
Write-Host "Instance: $InstanceId | Region: $AWS_REGION | Local Port: $LOCAL_PORT | Remote Port: $REMOTE_PORT"

aws ssm start-session --target $InstanceId `
    --document-name AWS-StartPortForwardingSession `
    --parameters @{portNumber= @($REMOTE_PORT); localPortNumber= @($LOCAL_PORT)} `
    --region $AWS_REGION
