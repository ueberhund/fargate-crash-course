# Create your first docker image

After the CloudFormation template has been run, do the following:

In Cloud9:
1. Navigate to lab-content/docker-sample-code/hello/
2. docker build -t demo .
3. docker run -it --rm -p 8080:80 demo  
4. Preview -> Preview Running Applications. You should see the container running in a web browser

In ECR:
1. Create a new repository and copy the URL

Back in Cloud9:
1. aws ecr get-login-password | docker login --username AWS --password-stdin ***ACCOUNT_ID***.dkr.ecr.REGION.amazonaws.com
2. docker tag demo ***ECR_REPO_NAME_FROM_STEP_1_ABOVE***
3. docker push ***ECR_REPO_NAME_FROM_STEP_1_ABOVE***

You have now successfully created a docker image and pushed it to ECR
