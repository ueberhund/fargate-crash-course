## Deploying to EKS

### Create an EKS cluster
1. Create a new EKS cluster. You can do this either through the console or the CLI. When creating a cluster, you provide some basic networking information and the EKS service role.
2. Once the cluster has been created (this may take 10-15 minutes), go into the node in the console and select the "Compute" tab. From here, you need to create a Node Group. You must select an IAM role for the node. I followed these directions: https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html#create-worker-node-role
3. Once created, you'll notice a few EC2 instances spin up, depending on the number of instances you specified.

### Deploy via kubectl
Once all of that is created, you now configure the cluster via kubectl
1. To configure kubectl, you call the CLI as follows:
$ aws eks --region <region> update-kubeconfig --name <cluster-name>
2. Once that is complete, you can now call kubectl and get information back about your EKS cluster:
$ kubectl get svc
3. To deploy, I created a simple container called hello-world (see docker-sample-code/hello/) and deployed it to EKS.
4. Update helloworld-eks.yml to contain the correct reference to the image (line 38)
5. Execute the following commands:
$ kubectl apply -f ./helloworld-eks.yml

This will create a load balancer and deploy 10 pods containing our container. After a few minutes, you should be able to see the load balancer appear in the EC2 console with all hosts healthy. You can then view the site in a browser.

## Deploying to EKS with Fargate

Deploying to EKS with Fargate is a little more complex. One important thing to note that when you call `kubectl` to create a loadbalancer, it creates a CLB behind the scenes. CLBs don't work with Fargate, so we need to intercept the CLB request to turn it into an ALB. This is also a great resource for understanding how EKS works with Fargate: https://www.learnaws.org/2019/12/16/running-eks-on-aws-fargate/

1. Start by creating a new cluster `eksctl create cluster --name <fargate-cluster-name> --version 1.16 --region <region> --fargate  --alb-ingress-access`. This creates a new EKS cluster with a Fargate profile. 
2. You can confirm the cluster is up and running by calling `kubectl get nodes`. You should notice some nodes that start with "fargate-ip" in the node list.
3. We now need to get the VPCId of the cluster for the next step. Call this command: `eksctl get cluster --region us-east-2 --name <fargate-cluster-name> -o yaml`
4. Now we need to set up an ALB Ingress Controller. Begin by downloading these two files:
````
wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
wget https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml
````
5. You need to edit the alb-ingress-controller.yaml file and modify the following fields: `cluster-name`, `vpc-id`, `aws-region`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY`. Note that using a secret key and token isn't a good practice so you should be using kube2iam (or similar) to provide IAM access.
6. Run both of these files by running:
````
kubectl apply -f rbac-role.yaml
kubectl apply -f alb-ingress-contorller.yaml
````
7. Run `kubectl apply -f helloworld-eks-fargate.yml` to deploy the fargate version of the hello-world app
8. After a few minutes, you should notice your ALB is up and active and your pods are all running. 

Congrats, you've just deployed an app to EKS with Fargate!
