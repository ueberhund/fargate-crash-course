#!/bin/bash

#export REGION=$(aws configure get region)

#Install prereqs
sudo yum install jq -y

#Get values needed for the rest of this script
export RoleArn=$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("ecsTaskExecutionRole")) | .Arn')
export LoadBalancerArn=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="LoadBalancerArn") | .OutputValue')
export VPCId=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="VPCId") | .OutputValue')
export PrivateSubnet1=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="PrivateSubnet1") | .OutputValue')
export PrivateSubnet2=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="PrivateSubnet2") | .OutputValue')
export PrivateSecurityGroup=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="PrivateSecurityGroup") | .OutputValue')

#Create a demo task
export RepoUrl=$(aws ecr describe-repositories | jq -r '.repositories[] | .repositoryUri')
aws ecs register-task-definition --execution-role-arn $RoleArn --family "demo-task" \
    --container-definition "[{\"name\": \"demo-task\", \"image\": \"$RepoUrl:latest\", \"portMappings\": [{\"containerPort\": 80, \"hostPort\": 80, \"protocol\": \"tcp\"}], \"essential\": true}]" \
    --network-mode "awsvpc" --requires-compatibilities "FARGATE" --cpu "256" --memory "512"

#Create the cluster
aws ecs create-cluster --cluster-name fargate-cluster --settings name=containerInsights,value=enabled

#Create target group
export TargetGroupArn=$(aws elbv2 create-target-group --name demo-target --protocol HTTP --port 80 --target-type ip --vpc-id $VPCId | jq -r '.TargetGroups[] | .TargetGroupArn')

#Create a listener
aws elbv2 create-listener --load-balancer-arn $LoadBalancerArn --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TargetGroupArn

#Deploy the service
aws ecs create-service --cluster fargate-cluster --service-name demo-service --task-definition demo-task --desired-count 2 \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$PrivateSubnet1,$PrivateSubnet2],securityGroups=[$PrivateSecurityGroup]}" \
    --load-balancers targetGroupArn=$TargetGroupArn,containerName=demo-task,containerPort=80
    
