# Kube App
A sample kubernetes app deployed in AWS EKS


## How to deploy
1. git clone <repo-url>

### Setup AWS access
``` 
	export AWS_SECRET_ACCESS_KEY=<Secret-access-key>
	export AWS_ACCESS_KEY_ID=< access-key-id >
	export AWS_REGION=ap-southeast-2
```

#### Deploy EKS Cluster
```
	# Terraform must have been downloaded
	cd infra
	terraform apply -auto-approve
```
Note - The terraform deployment creates the following resources

1. A VPC with public and private subnets
2. An AWS EKS Cluster with 2 workder groups
3. Two security groups, one per worker group
4. Two ECR repositories, namely 
	eks-api -  An ECR that contains a lightweight nginx image with the api
	codebuild-alpine - An ECR that contains the alpine image and will be used in codebuild projects

5. Once cluster deployment is complete, update the kube config using

 	```aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)```
#### Build and push images
```
	cd /kube_app (route folder of the repository)
	
	make build-pipeline-ecr
```
Note - The above will build and push these images into ECR

#### Run Deployment followed by service
 ```
 	cd app
 	kubectl apply -f deployment.yaml
 	kubectl apply -f service.yaml
 ```

## Considerations

