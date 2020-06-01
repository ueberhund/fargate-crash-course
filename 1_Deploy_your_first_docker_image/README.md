# Deploy your first docker image

To deploy to Fargate

Start by creating a new task in ECS:

1. Go to Task Definitions
2. Click the Create new Task Definition button
3. Pick Fargate as the launch type
4. Give the task definition a name (like "demo-task")
5. Pick the ecsTaskExecutionRole
6. Select 0.5GB for the task memory and 0.25 vCPU for the task CPU
7. Click the "Add container" button.
    a. Give the container a name "demo-task"
    b. Provide the URL of the container version from ECR in the Image field
    c. Put 80 in the continaer port
    d. Click the "Add" button
8. Click the "Create" button

Now create a new cluster in ECS:
1. Click "Clusters", and the "Create Cluster" button
2. Pick "Networking only" for the cluster template and click "Next step"
3. Give the cluster a name (like "demo-cluster")
4. Make sure CloudWatch Container Insights are enabled
5. Click "Create"

Now deploy the task in the cluster:
1. In the cluster, make sure you're on the "Services" tab and click the "Create" button
2. Pick "Fargate" as the launch type
3. Pick the demo-task as the task family and enter a name for the Service name (like "demo-service")
4. Enter "2" for the number of tasks
5. Click "Next step"
6. Pick the the VPC with the name that starts with "FargateVPC" (you may need to navigate to the VPC console to see the VPC ID)
7. Pick "PrivateSubnet1" and "PrivateSubnet2" as the subnets
8. Change the security group to be the one that stars with PrivateSecurityGroup
9. Select "Application Load Balancer" and pick "Fargate-ALB"
10. Click the "Add to load balaner" button
11. Enter "80" as the production port listener
12. Change the target group name to be "demo-target"
13. Uncheck the box that says "Enable service discovery integration"
14. Click "Next step"
15. Click "Next step"
16. Click "Create Service"

After a few moments, the Fargate tasks should spin up, and you should have a website available at the DNS of the Fargate-ALB application load balancer

