param (
    [string]$InstanceId
)

if (-not $InstanceId) {
    Write-Host "Usage: .\start-ssm-session.ps1 -InstanceId <INSTANCE_ID>"
    exit 1
}

$AWS_REGION = "eu-west-2"

Write-Host "Starting AWS SSM session for instance: $InstanceId in region: $AWS_REGION..."
aws ssm start-session --target $InstanceId --region $AWS_REGION
