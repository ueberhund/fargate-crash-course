# Setting up a container to run within Lambda

This code configures a container that can be run within Lambda. The function simply returns the JSON of a sample 
data file, which contains dummy data. 

This container was set up based on directions from this article [1]. A couple of problems that I had in building this container:

1. The container needs to support the open-source runtime interface client [2]. You can either install the runtime yourself, or you can use an image that's pre-built by AWS. I had trouble getting a container to work with the RIC, so I ended up using a pre-built python container.

2. AWS base images provide a couple of environment variables. One of which is LAMBDA_TASK_ROOT. I ended up modifying my container to put all the files in this directory, which seemed to help everything work correctly.

Once you get the container set up, push it to ECR. Go into Lambda and create a new container image. Once you hit "Create", it takes a minute for the function to be set up. I then created a new test event, and I was able to see the JSON returned when I executed the test event. This lambda function uses pandas, which normally requires you to use a Lambda layer. If you have an existing container workflow, this may be easier to build then creating custom layers.

[1] https://docs.aws.amazon.com/lambda/latest/dg/images-create.html

[2] https://docs.aws.amazon.com/lambda/latest/dg/runtimes-images.html#runtimes-api-client
