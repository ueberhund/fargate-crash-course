# Set up a new app with Blue/Green deploy

1. Set up two new containers to test out Blue/Green deploys by running scripts/build-catnip.sh
2. Create a new task
  a. Select Fargate as the lauynch type
  b. Give the task definition a name of "catnip"
  c. Pick the ECSTaskExecutionRole for the task role
  d. Select 0.5GB for the memory and 0.25vCPU for the CPU
  e. Click the "Add continer" button
  f. Give the container the name of catnip, and add the V1 image URL from ECS
  g. Add 5000 to the port mapping and click the "Add" button at the bottom of the page
  h. Click the "Create" button
3. Add a new version of the task
  a. Click the "Create new revision" button
  b. Click the container and change the image to the V2 image URL from ECS
  c. Click the "Update" button and then the "Create" button

You should now have 2 versions of the catnip task
  
Now create a blue/green enabled cluster in ECS
1. In the demo-cluster, create a new service called 
  a. Select Fargate as the launch type
  b. 
  b. "blue-green-service"
