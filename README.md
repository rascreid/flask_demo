# notejam_flask

### 1. Add Jenkins jobs to Jenkins

And call them accordingly. There should be 4 pipelines:
- Common create
- Common destroy
- Main create
- Main destroy

Common pipelines creates basic environment include IAMs, S3 and DynamoDBs, ECR and SGs

Main pipeline:
1. Builds Flask from sources, pack it to Docker and push it to ECR
2. Creates ECS environment which uses this docker image

### 2. Failover
Terraform creates 2 AZs per region and uses Autoscaling group with Load Balancer.
if you want to create environment in another region, choose new region from pop-up in Jenkins.
You can use two regions at the same time.

### 3. DNS
I didn't create DNS records via R53. You can find ALB dynamic DNS record at end of the main Jenkins pipeline console output.

### 4. New versions of app
 If you modified app sources, just run `Main create` pipeline. There should be separate pipeline with git trigger (in TO-DO)

### 5. TO-DO
- There are a lot of hardcoded things, basically now you can't change env from dev to another
- Need to create separate pipeline to build new versions of app and it should be git triggered
- Maybe it'd be better to create some self-deployed Jenkins in AWS for this demo using JCasC
- There are no any health checks

#### Notes
1. I modified original flask example to listen from everywhere
2. Original 5000 port redirected to 8080 port in ALB
3. ASG uses 4 EC2 instances for non-interruption deploy. ECS creates new instances and check them before swith to new deployment
4. I'm using ASG only for deployment in different AZs and check their health. There is no any autoscaling depends on load
