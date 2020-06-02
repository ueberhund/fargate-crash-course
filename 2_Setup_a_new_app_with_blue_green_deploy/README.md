# Set up a new app with Blue/Green deploy

1. Create a new role to allow CodeDeploy to access ECS resources on your behalf

  a. Go to the IAM console and click "Create Role"
  b. From the list of services, pick "CodeDeploy", then "CodeDeploy - ECS", then click the "Permissions" button
  c. Click the "Tags" button, and "Next: Review"
  d. Give your role a name (like "ecsCodeDeployRole") and click the "Create Role" button
  
2. Set up two new containers to test out Blue/Green deploys by running scripts/build-catnip.sh

3. Create a new task

  a. Select Fargate as the lauynch type
  b. Give the task definition a name of "catnip"
  c. Pick the ECSTaskExecutionRole for the task role
  d. Select 0.5GB for the memory and 0.25vCPU for the CPU
  e. Click the "Add continer" button
  f. Give the container the name of catnip, and add the V1 image URL from ECS
  g. Add 5000 to the port mapping and click the "Add" button at the bottom of the page
  h. Click the "Create" button

4. Add a new version of the task

  a. Click the "Create new revision" button
  b. Click the container and change the image to the V2 image URL from ECS
  c. Click the "Update" button and then the "Create" button

You should now have 2 versions of the catnip task
  
Now create a blue/green enabled cluster in ECS

5. In the demo-cluster, create a new service to support our Blue/Green application

  a. Select Fargate as the launch type
  b. Select catnip as the task definition, and 1 as the revision 
  c. If this service the name of "blue-green-service" with 2 tasks
  d. Under "Deployments", pick "Blue/green deployment", pick CodeDeployDefault.ECSAllAtOnce for the deployment configuration and select the role you created in step #1 above for the CodeDeploy service role
  e. Click "Next step"
  f. Select the FargateVPC as the cluster VPC (you may need to look up it's VPC Id from the VPC console), and add in the private subnets for this VPC
  g. Select the PrivateSecurityGroup from this VPC and click "Save"
  h. Select "Application Load Balancer" and select the Fargate-ALB that we've been using for these labs
  i. Click the "Add to load balancer" button
  j. Select port 80 as the production listener port, enter 8888 as the test listener port
  k. In target group 1, enter the name as "catnip-target1", the path as "/catnip*" and the evaluation as 1
  l. In the health check, change the path to "/"
  m. In target group 2, enter the name as "catnip-target2"
  n. Uncheck "Enable service discovery integration" and click "Next step"
  o. Click "Next step" and "Create service"
  
You should see v1 of the catnip application appear on the /catnip path of the application load balancer
