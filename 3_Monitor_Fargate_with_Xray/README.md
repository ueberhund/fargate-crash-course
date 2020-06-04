## Monitor Fargate with X-Ray

You'll notice that when you built the catnip containers, you actually ended up building 3 versions of it. So far, we've used v1 and v2. V3 has been created to support [X-Ray](https://aws.amazon.com/xray/).

To deploy this new version in your cluster, do the following:
- Go into the catnip task and create a new revision. Change the container image to point to v3 of the container and click "Update"
- Click the "Add container" button and enter the container name as "aws-ray" and the image as "amazon/aws-xray-daemon". Under port mappings, add in 2000 and change the protocol to udp. Click the "Add container" button. 
- Take note of the Task Role that is being used. 
- Click the "Create" button.
- Now go to the IAM console that you're running your task under (mine is called ecsTaskExecutionRole) and add `AWSXRayDaemonWriteAccess` and `AmazonDynamoDBReadOnlyAccess` policies to this role.

This new task is now configured to run AWS X-Ray as a container sidecar. If you want to better understand X-Ray, I recommend [starting here](https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html). 

Now perform a Blue/Green deploy of the container to your existing cluster. Once it's complete, your website should look just like the version 2 did. However, if you go into the X-Ray console, you should now see the resources showing up on the service map. If you want to increase the resources on the service map, simply create more DynamoDB tables. 


### Notes
If you want to test a container locally and that container requries AWS permissions, this blog post is worth reading:
https://aws.amazon.com/blogs/compute/a-guide-to-locally-testing-containers-with-amazon-ecs-local-endpoints-and-docker-compose/
