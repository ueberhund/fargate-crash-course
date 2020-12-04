#!/usr/bin/env python3

from aws_cdk import core, aws_ecs, aws_ecr, aws_iam, aws_ec2


class CircuitBreakerDemo(core.Stack):

    def __init__(self, scope: core.Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        # The code that defines your stack goes here
        ecs_cluster = aws_ecs.Cluster(
            self, "DemoCluster",
            cluster_name="CB-Demo"
        )

        # ECR Image Repo 
        ecr_repo = aws_ecr.Repository(self, "ECRRepo", repository_name="flask-cb-demo")

        # IAM Policy
        iam_policy = aws_iam.PolicyDocument(
            statements = [
                aws_iam.PolicyStatement(
                    actions = [
                        "ecr:BatchCheckLayerAvailability",
                        "ecr:GetDownloadUrlForLayer",
                        "ecr:BatchGetImage"
                    ],
                    resources = [ ecr_repo.repository_arn ]
                ),
                aws_iam.PolicyStatement(
                    actions = [
                        "ecr:GetAuthorizationToken"
                    ],
                    resources = [ "*" ]
                ),
            ]
        )
        
        # IAM Task Role
        task_execution_role = aws_iam.Role(
            self, "TaskExecutionRole",
            role_name="CircuitBreakerDemoRole",
            assumed_by=aws_iam.ServicePrincipal(service="ecs-tasks.amazonaws.com"),
            inline_policies = [
                iam_policy
            ]
        )
        
        security_group = aws_ec2.SecurityGroup(
            self, "WebSecGrp",
            vpc=ecs_cluster.vpc
        )
        
        security_group.connections.allow_from_any_ipv4(
            port_range=aws_ec2.Port(
                protocol=aws_ec2.Protocol.TCP,
                string_representation="Web Inbound",
                from_port=5000,
                to_port=5000
            ),
            description="Web ingress"
        )
        
        core.CfnOutput(
            self, "IAMRoleArn",
            value=task_execution_role.role_arn,
            export_name="IAMRoleArn"
        )
        
        core.CfnOutput(
            self, "PublicSubnets",
            value=",".join([x.subnet_id for x in ecs_cluster.vpc.public_subnets]),
            export_name="PublicSubnets"
        )

        core.CfnOutput(
            self, "SecurityGroupId",
            value=security_group.security_group_id,
            export_name="SecurityGroupId"
        )
        
        core.CfnOutput(
            self, "EcrRepoUri",
            value=ecr_repo.repository_uri,
            export_name="EcrRepoUri"
        )
        

app = core.App()
CircuitBreakerDemo(app, "circuit-breaker-demo")
app.synth()