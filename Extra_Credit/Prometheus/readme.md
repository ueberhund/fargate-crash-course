## Prometheus

AWS released the ability to ingest Prometheus metrics from container environments into CloudWatch [1]. This release allows you to monitor aspects of a container that we haven’t been able to view to this point. In this example, I’m looking at JVM/Java statistics. Unfortunately, I found that the AWS documentation is pretty good for configuring this for EKS, but it’s a bit spotty in parts for ECS/Fargate.

A couple of notes:

- I started by building a new docker image (using the included Dockerfile). This docker image uses some config files pulled from our EKS example site [2] and the JMX exporter found here [3]. The war file I’m deploying is the Tomcat example [4] from the Elastic Beanstalk demo site. I used the tomcat.zip file from this site (renamed to .war) simply because I wanted something simple to deploy.
- The docker image in the previous step is configured to respond on :8080 at /tomcat/ for the public website and :9404 at /metrics/ for the Prometheus metrics
- When you send Prometheus metrics to CloudWatch, you have a separate container (running the CloudWatch Prometheus agent), which scrapes metrics from the /metrics/ path of the running containers and sends those to CloudWatch in the embedded metric format [5].

Ok, so here are the steps I followed to deploy this:
1. Build the docker image and push to ECR
2. Create a new task. Provide the task the image URL from step #1. In port mappings, make sure to map both ports 8080 and 9404. Remember that 8080 is for the website and 9404 is for the Prometheus metrics. Under “Docker Labels”, I added two key/value pairs: Java_EMF_Metrics with value true and ECS_PROMETHEUS_EXPORTER_PORT with value 9404. These values are used by Prometheus to auto-discover containers
3. Create a new Fargate cluster in the ECS console. I called my cluster “hello-world-java”. Create a new service with that cluster (mine was called “hello-world-svc”) and deploy the task from the previous step. A couple of notes:
  a. I deployed 2 replicas/tasks
  b. I configured my ALB to listen on port 80 (“production listener port”) and load balance to the container on port 8080. I created a new target group, and changed the health check path to “/tomcat/” (notice the trailing ‘/’).
  c. After deploying, verify that your site comes up correctly at http://ALB-DNS-NAME/tomcat/
4. I deployed a new service within my ECS cluster to handle the Prometheus metrics. To deploy this service, I ran prometheus-install.sh, which runs a CloudFormation script to deploy. You’ll want to change the values of the first 7 lines of that script to match your environment. If you look at the CFN template, it sets up a few values in Parameter Store, which tell the Prometheus task how it should be configured and what metrics to pull [6]

After a few moments, go to CloudWatch and under Metrics, you’ll see a new namespace called ECS/ContainerInsights/Prometheus containing your new metrics. You’ll also see a dashboard under Container Insights->Performance Monitoring that shows ECS Prometheus Java/JMX data for your instrumented containers.


[1] https://aws.amazon.com/about-aws/whats-new/2020/09/amazon-cloudwatch-monitors-prometheus-metrics-container-environments/

[2] https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus-Sample-Workloads-javajmx.html#ContainerInsights-Prometheus-Sample-Workloads-javajmx-jar

[3] https://github.com/prometheus/jmx_exporter

[4] https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/tutorials.html

[5] https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format.html

[6] https://github.com/aws-samples/amazon-cloudwatch-container-insights/tree/master/ecs-task-definition-templates/deployment-mode/replica-service/cwagent-prometheus
