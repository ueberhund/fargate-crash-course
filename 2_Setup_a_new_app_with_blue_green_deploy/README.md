# Set up a new app with Blue/Green deploy

1. Create a new role to allow CodeDeploy to access ECS resources on your behalf
- Go to the IAM console and click "Create Role"
- From the list of services, pick "CodeDeploy", then "CodeDeploy - ECS", then click the "Permissions" button
- Click the "Tags" button, and "Next: Review"
- Give your role a name (like "ecsCodeDeployRole") and click the "Create Role" button
  
  
2. Set up two new containers to test out Blue/Green deploys by running scripts/build-catnip.sh


3. Create a new task
- Select Fargate as the lauynch type
- Give the task definition a name of "catnip"
- Pick the ECSTaskExecutionRole for the task role
- Select 0.5GB for the memory and 0.25vCPU for the CPU
- Click the "Add continer" button
- Give the container the name of catnip, and add the V1 image URL from ECS
- Add 5000 to the port mapping and click the "Add" button at the bottom of the page
- Click the "Create" button

4. Add a new version of the task
- Click the "Create new revision" button
- Click the container and change the image to the V2 image URL from ECS
- Click the "Update" button and then the "Create" button

You should now have 2 versions of the catnip task
  
Now create a blue/green enabled cluster in ECS

5. In the demo-cluster, create a new service to support our Blue/Green application
- Select Fargate as the launch type
- Select catnip as the task definition, and 1 as the revision 
- If this service the name of "blue-green-service" with 2 tasks
- Under "Deployments", pick "Blue/green deployment", pick CodeDeployDefault.ECSAllAtOnce for the deployment configuration and select the role you created in step #1 above for the CodeDeploy service role
- Click "Next step"
- Select the FargateVPC as the cluster VPC (you may need to look up it's VPC Id from the VPC console), and add in the private subnets for this VPC
- Select the PrivateSecurityGroup from this VPC and click "Save"
- Select "Application Load Balancer" and select the Fargate-ALB that we've been using for these labs
- Click the "Add to load balancer" button
- Select port 80 as the production listener port, enter 8888 as the test listener port
- In target group 1, enter the name as "catnip-target1", the path as "/catnip*" and the evaluation as 1
- In the health check, change the path to "/"
- In target group 2, enter the name as "catnip-target2"
- Uncheck "Enable service discovery integration" and click "Next step"
- Click "Next step" and "Create service"
  
You should see v1 of the catnip application appear on the /catnip path of the application load balancer
