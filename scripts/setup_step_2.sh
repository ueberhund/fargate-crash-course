#!/bin/bash

#export REGION=$(aws configure get region)

#Get values needed for the rest of this script
export RoleArn=$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("ecsTaskExecutionRole")) | .Arn')
export LoadBalancerArn=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="LoadBalancerArn") | .OutputValue')
export VPCId=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="VPCId") | .OutputValue')
export PrivateSubnet1=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="PrivateSubnet1") | .OutputValue')
export PrivateSubnet2=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="PrivateSubnet2") | .OutputValue')
export PrivateSecurityGroup=$(aws cloudformation describe-stacks | jq -r '.Stacks[] | select(.StackName | contains("fargate")) | .Outputs[] | select(.OutputKey=="PrivateSecurityGroup") | .OutputValue')

#Install prereqs
sudo yum install jq -y

#Create a new role for CodeDeploy
aws iam create-role --role-name ecsCodeDeployRole --assume-role-policy-document "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Principal\": {\"Service\": \"codedeploy.amazonaws.com\"},\"Action\": \"sts:AssumeRole\"}]}"
aws iam attach-role-policy --role-name ecsCodeDeployRole --policy-arn arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS
export CodeDeployRoleArn=$(aws iam list-roles | jq -r '.Roles[] | select(.RoleName | contains("ecsCodeDeployRole")) | .Arn')

#Build out the catnip containers
./build-catnip.sh

#Create 3 new tasks
export RepoUrl=$(aws ecr describe-repositories | jq -r '.repositories[] | select(.repositoryUri | contains("catnip")) | .repositoryUri')
#V1
aws ecs register-task-definition --execution-role-arn $RoleArn --family "catnip" \
    --container-definition "[{\"name\": \"catnip\", \"image\": \"$RepoUrl:v1\", \"portMappings\": [{\"containerPort\": 5000, \"hostPort\": 5000, \"protocol\": \"tcp\"}], \"essential\": true}]" \
    --network-mode "awsvpc" --requires-compatibilities "FARGATE" --cpu "256" --memory "512"
#V2
aws ecs register-task-definition --execution-role-arn $RoleArn --family "catnip" \
    --container-definition "[{\"name\": \"catnip\", \"image\": \"$RepoUrl:v2\", \"portMappings\": [{\"containerPort\": 5000, \"hostPort\": 5000, \"protocol\": \"tcp\"}], \"essential\": true}]" \
    --network-mode "awsvpc" --requires-compatibilities "FARGATE" --cpu "256" --memory "512"
#V3
aws ecs register-task-definition --execution-role-arn $RoleArn --family "catnip" \
    --container-definition "[{\"name\": \"catnip\", \"image\": \"$RepoUrl:v3\", \"portMappings\": [{\"containerPort\": 5000, \"hostPort\": 5000, \"protocol\": \"tcp\"}], \"essential\": true}]" \
    --network-mode "awsvpc" --requires-compatibilities "FARGATE" --cpu "256" --memory "512"    


#Create target group
export TargetGroupArn1=$(aws elbv2 create-target-group --name catnip-target1 --protocol HTTP --port 5000 --target-type ip --vpc-id $VPCId --health-check-path /catnip | jq -r '.TargetGroups[] | .TargetGroupArn')
export TargetGroupArn2=$(aws elbv2 create-target-group --name catnip-target2 --protocol HTTP --port 5000 --target-type ip --vpc-id $VPCId --health-check-path /catnip | jq -r '.TargetGroups[] | .TargetGroupArn')

#Update the listener to support the new target groups
export ListenerArn=$(aws elbv2 describe-listeners --load-balancer-arn $LoadBalancerArn | jq -r '.Listeners[] | .ListenerArn')
aws elbv2 create-rule --listener-arn $ListenerArn --priority 1 --conditions "[{\"Field\":\"path-pattern\",\"PathPatternConfig\":{\"Values\":[\"/catnip*\"]}}]" --actions Type=forward,TargetGroupArn=$TargetGroupArn1

#Deploy the service
aws ecs create-service --cluster fargate-cluster --service-name catnip-service --task-definition catnip:1 --desired-count 2 \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$PrivateSubnet1,$PrivateSubnet2],securityGroups=[$PrivateSecurityGroup]}" \
    --load-balancers targetGroupArn=$TargetGroupArn1,containerName=catnip,containerPort=5000 \
    --deployment-controller type=CODE_DEPLOY

#Create a Blue/Green deployment with CodeDeploy
aws deploy create-application --application-name catnip-app --compute-platform ECS

aws deploy create-deployment-group --application-name catnip-app --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
    --deployment-group-name catnip-dg --service-role-arn $CodeDeployRoleArn \
    --auto-rollback-configuration "{\"enabled\": true,\"events\": [\"DEPLOYMENT_FAILURE\",\"DEPLOYMENT_STOP_ON_REQUEST\"]}" \
    --deployment-style "{\"deploymentType\": \"BLUE_GREEN\",\"deploymentOption\": \"WITH_TRAFFIC_CONTROL\"}" \
    --blue-green-deployment-configuration "{\"terminateBlueInstancesOnDeploymentSuccess\": {\"action\": \"TERMINATE\",\"terminationWaitTimeInMinutes\": 5},\"deploymentReadyOption\": {\"actionOnTimeout\": \"CONTINUE_DEPLOYMENT\",\"waitTimeInMinutes\": 0}}" \
    --load-balancer-info "{\"targetGroupPairInfoList\": [{\"targetGroups\": [{\"name\": \"catnip-target1\"},{\"name\": \"catnip-target2\"}],\"prodTrafficRoute\": {\"listenerArns\": [\"$ListenerArn\"]}}]}" \
    --ecs-services "[{\"serviceName\": \"catnip-service\",\"clusterName\": \"fargate-cluster\"}]"