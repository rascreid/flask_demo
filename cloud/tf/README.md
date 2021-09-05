# notejam_flask

### 1. Create init s3 bucket via CLI

```
aws s3api create-bucket --bucket flask-dev-use1 --region us-east-1
```

## 2. Run Common terraform resources
### Create
```
cd cloud/tf/common
terraform init  -backend-config="bucket=flask-dev-use1" -backend-config="key=tf_states/terraform.tfstate" -backend-config="region=us-east-1" -reconfigure
terraform plan -var="environment_type=dev" -var="aws_region=us-east-1" -var-file=terraform.tfvars -out out.out
terraform apply out.out
```

### Destroy
```
cd cloud/tf/common
terraform init  -backend-config="bucket=flask-dev-use1" -backend-config="key=tf_states/terraform.tfstate" -backend-config="region=us-east-1" -reconfigure
terraform destroy -var="environment_type=dev" -var="aws_region=us-east-1" -var-file=terraform.tfvars -auto-approve
```

## 3. Run main terraform stuff
```
cd cloud/tf
terraform init -backend-config="bucket=flask-tfstate-dev-use1" -backend-config="key=tf_states/terraform.tfstate" -backend-config="region=us-east-1" -backend-config="dynamodb_table=flask-tfstate-lock-dev-use1" -backend-config="encrypt=true" -reconfigure
terraform plan -var="environment_type=dev" -var="aws_region=us-east-1" -var-file=terraform.tfvars -out out.out
terraform apply out.out
```


```
terraform destroy -var="environment_type=dev" -var="aws_region=us-east-1" -var-file=terraform.tfvars -auto-approve
```
