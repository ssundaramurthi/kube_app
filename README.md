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

## Recommendations

1. Automate using terraform to create a network loadbalancer along with a listener and a target group. 
2. Move the nodes to private subnets and update security groups to receive traffic from loadbalancer only on non-ephemeral ports
3. Update security groups for nodes to accept traffic from your IP on port 31001. Since this is done to test the deployments
4. Review IAM policy of codepipeline and codebuild
5. Scan on push have been turned on by default on ECR repositories. Review the high vulnerabilities and patch the same.
6. Setup Codepipeline and Github action to test changes on infra and app upon pull request creation. Implementation details - will need to be reviewed
   1. Codepipeline shall contain 4 stages.
       1. Source - This stage will source the code and store in an artefact bucket
       2. Build - Builds the app, and conducts tests on the same. Updates result back to github commit. Upon successful completion, sends message to involved parties to review and approve
       3. Approve - This is a manual step that the approvers conduct in order for the pipeline to proceed
       4. Deploy - Deploy the app and send out notifications to the Engineering teams
   2. This point in App lifecycle, the pipeline can  be extended to promote the artifact from build stage into staging environment. However this will have to a manual trigger
   3. Once staging is validated for, step 2 can be repeated for production. Again this will be a manual trigger.
   4. If steps 2 and 3 are not feasible due to maturity of DevOps team, then setup similar pipelines for staging and production environments
7. Setup the kuberenetes app to push access and error logs to Cloudwatch. This must be then ingested into SoC provider (eg: Splunk, QRadar) for ongoing monitoring
8. Setup Kubernetes dashboard to monitor 
   1. Setup Kubernetes metrics server
   2. Create a service account to use with the dashboard using RBAC authorization and ensure this has cluster-admin privileges 
   3. Once done, get the auth token, start the kube control proxy, launch the kube dashboard and connect using the token
   4. Prometheus is another alternative to default kube dashboard
   

9. Once all has been completed run `terraform destroy` to delete the cluster and associated resources

Tips:
1. If you're planning to use EKS with terraform, it'd be a good idea to separate the provider and EKS cluster definitions in separate directories since the provider will need to be initiated prior to eks.

## To Do
1. Setup codepipeline and verify deployments