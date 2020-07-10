## Deploying to EKS

### Create an EKS cluster
1. Create a new EKS cluster. You can do this either through the console or the CLI. When creating a cluster, you provide some basic networking information and the EKS service role.
2. Once the cluster has been created (this may take 10-15 minutes), go into the node in the console and select the "Compute" tab. From here, you need to create a Node Group (if using vanilla EKS) or a Fargate Profile (if using EKS with Fargate). I ended up creating a new node group. You must select an IAM role for the node. I followed these directions: https://docs.aws.amazon.com/eks/latest/userguide/worker_node_IAM_role.html#create-worker-node-role
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
