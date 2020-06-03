## Extra Credit

If you want to enable Blue/Green deploys while testing your site before live traffic is sent to it, you'll need to use CodeDeploy directly.

Follow the steps in [2_Setup_a_new_app_with_blue_green_deploy](../2_Setup_a_new_app_with_blue_green_deploy).
When setting up your production listener port (step #10), also add a test listener. I added port 8080 as my test listener. You'll also need to update your inbound security group to allow access through port 8080.

Next create an [AppSpec.yml](ecsAppSpec.yml) file

### Some things to know about CodeDeploy
You can see the configuration for your application's CodeDeploy by going to the CodeDeploy console. Under "Application" pick the application that was set up for you. Under "Deployment groups", pick the deployment group that corresponds to your Blue/Green deploy. Click the "Edit" button.

You don't need to edit anything here, but a few things to keep in mind:

1. If you want to run some automated tests and then re-route production traffic based on the results of those tests, you want the Traffic rerouting option set to "Reroute traffic immediately". The option "Specify when to reroute traffic" puts your deploy into a state that once all tests pass, it will sit for the time period you specify until 1) it times out, or 2) you tell it to re-route traffic by calling `aws deploy continue-deployment --deployment-id YOUR_DEPLOYMENT_ID`

2. The "original revision termination" fields define how long your blue task will remain available before it's auto-terminated. This is useful in case you deploy but then discover a problem and need to roll back. For POC purposes, I keep my tasks around for 5 minutes.

### How to perform an ECS deploy via CodeDeploy
After selecting your application and deployment group, click the "Create deployment" button. You provide it a copy of your AppSpec file and click "Create deployment". If your AppSpec specifies a Lambda function for the AfterAllowTestTraffic hook, you'll see it execute. This [example lambda function](AfterAllowTestTraffic.js) will give you a good start.

To execute the Lambda function, you should set up a new role (I called mine **lambda-cli-hook-role**). The role should have AWSLambdaBasicExecutionRole and you must assign a custom policy to it and grant `codedeploy:PutLifecycleEventHookExecutionStatus` permissions. 
