# scripts/deploy-stack.ps1
# Deploys a CloudFormation stack with parameters from a JSON file

param(
    [string]$StackName = "dev-ec2-instance",
    [string]$TemplatePath = "./templates/ec2-instance.yml",
    [string]$ParametersPath = "./parameters/dev-params.json",
    [string]$Region = "us-east-1"
)

Write-Host "Deploying stack '$StackName' in region '$Region' using template '$TemplatePath'..."

# Validate the template
aws cloudformation validate-template `
    --template-body file://$TemplatePath `
    --region $Region

if ($LASTEXITCODE -ne 0) {
    Write-Host "Template validation failed. Exiting." -ForegroundColor Red
    exit 1
}

# Deploy the stack
aws cloudformation deploy `
    --stack-name $StackName `
    --template-file $TemplatePath `
    --parameter-overrides (Get-Content $ParametersPath | ConvertFrom-Json | ForEach-Object { "$($_.ParameterKey)=$($_.ParameterValue)" }) `
    --capabilities CAPABILITY_NAMED_IAM `
    --region $Region

if ($LASTEXITCODE -eq 0) {
    Write-Host "Stack '$StackName' deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "Stack deployment failed." -ForegroundColor Red
}
