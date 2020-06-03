# Set up a new app with Blue/Green deploy

## Create a new role to allow CodeDeploy to access ECS resources on your behalf
1. Go to the IAM console and click "Create Role"
2. From the list of services, pick "CodeDeploy", then "CodeDeploy - ECS", then click the "Permissions" button
3. Click the "Tags" button, and "Next: Review"
4. Give your role a name (like "ecsCodeDeployRole") and click the "Create Role" button
  
Set up two new containers to test out Blue/Green deploys by running scripts/build-catnip.sh

## Create a new task
1. Select Fargate as the launch type
2. Give the task definition a name of "catnip"
3. Pick the ECSTaskExecutionRole for the task role
4. Select 0.5GB for the memory and 0.25vCPU for the CPU
5. Click the "Add continer" button
6. Give the container the name of catnip, and add the V1 image URL from ECS
7. Add 5000 to the port mapping and click the "Add" button at the bottom of the page
8. Click the "Create" button

## Add a new version of the task
1. Click the "Create new revision" button
2. Click the container and change the image to the V2 image URL from ECS
3. Click the "Update" button and then the "Create" button

You should now have 2 versions of the catnip task
  
## Create a blue/green enabled cluster in ECS

In the demo-cluster, create a new service to support our Blue/Green application
1. Select Fargate as the launch type
2. Select catnip as the task definition, and 1 as the revision 
3. If this service the name of "blue-green-service" with 2 tasks
4. Under "Deployments", pick "Blue/green deployment", pick CodeDeployDefault.ECSAllAtOnce for the deployment configuration and select the role you created in step #1 above for the CodeDeploy service role
5. Click "Next step"
6. Select the FargateVPC as the cluster VPC (you may need to look up it's VPC Id from the VPC console), and add in the private subnets for this VPC
7. Select the PrivateSecurityGroup from this VPC and click "Save"
8. Select "Application Load Balancer" and select the Fargate-ALB that we've been using for these labs
9. Click the "Add to load balancer" button
10. Select port 80 as the production listener port
11. In target group 1, enter the name as "catnip-target1", the path as "/catnip*" and the evaluation as 1
12. In the health check, change the path to "/catnip"
13. In target group 2, enter the name as "catnip-target2"
14. Uncheck "Enable service discovery integration" and click "Next step"
15. Click "Next step" and "Create service"
  
You should see v1 of the catnip application appear on the /catnip path of the application load balancer

## Begin a blue/green deploy

1. Go into the catnip-service and select the "Update" button
2. Change the task definition to the latest version, which will trigger a blue/green deploy
3. Click "Next step"
4. Click "Next step", "Next step", "Next step", and "Update service"

You will see the deploy occur in the CodeDeploy console. Once the deploy has successfully deployed the updates, you'll see those reflected at the URL. The old tasks will be deleted per CodeDeploy's configuration.

### Notes

Be aware that the lifecycle hook (**AfterAllowTestTraffic**) required to test traffic BEFORE live traffic is sent over is not enabled at this time within the ECS console. If you want to enable Blue/Green with testing the site before live traffic is redirected, you'll need to use CodeDeploy directly. See the Extra_Credit section for details on that.
