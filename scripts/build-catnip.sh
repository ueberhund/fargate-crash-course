#!/bin/bash

export REGION=us-west-2

#Install prereqs
sudo yum install jq -y

#Set up the new repository
export REPO=$(aws ecr create-repository --repository-name catnip | jq -r '.repository.repositoryUri')

#Build and push the image for v1
cd ../docker-sample-code/catnipv1/
docker build -t catnip .

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity | jq -r '.Account').dkr.ecr.$REGION.amazonaws.com

docker tag catnip:latest catnip:v1
docker tag catnip:v1 $REPO:v1
docker push $REPO:v1

#Build and push the image for v2
cd ../catnipv2/
docker build -t catnip .
docker tag catnip:latest catnip:v2
docker tag catnip:v2 $REPO:v2
docker push $REPO:v2

#Build and push the image for v3
cd ../catnip-sidecar/
docker build -t catnip .
docker tag catnip:latest catnip:v3
docker tag catnip:v3 $REPO:v3
docker push $REPO:v3
