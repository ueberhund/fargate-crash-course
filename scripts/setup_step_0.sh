#!/bin/bash

export REGION=$(aws configure get region)

#Install prereqs
sudo yum install jq -y

#Set up the new repository
export REPO=$(aws ecr create-repository --repository-name demo | jq -r '.repository.repositoryUri')

#Build and push the image for v1
cd ../docker-sample-code/hello/
docker build -t demo .

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity | jq -r '.Account').dkr.ecr.$REGION.amazonaws.com

docker tag demo $REPO
docker push $REPO