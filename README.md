# Initial Configuration

## About
Simple AWS ECS cluster deployment

## Install locally
```
awscli
terragrunt
```

## To configure remote terraform state
1. Create a new S3 bucket within the 'us-east-1' region;
2. Change the bucket name "remote_state.config.bucket" from "aws/{env}/terragrunt.hcl";
3. Create a new dynamodb table with name 'terraform_lock' within 'us-east-1' region;

## Apply
```
cd aws/prd/us-east-1/network/
terragrunt plan
terragrunt apply
```
```
cd aws/prd/us-east-1/route53/
terragrunt plan
terragrunt apply
# Validate the domain using ACM!
```
```
cd aws/prd/us-east-1/cluster/ecs/
terragrunt plan
terragrunt apply
```

```
cd aws/prd/us-east-1/services/backend/
terragrunt plan
terragrunt apply
```


