data "aws_region" "current" {}
data "aws_caller_identity" "current" {}



resource "aws_iam_user" "codedeploy_user" {
  name = "webapp"
  path = "/"
}

resource "aws_iam_user_policy" "webapp_deploy" {
  name = "DeployWebapp"
  user = "${aws_iam_user.codedeploy_user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "1",
        "Effect": "Allow",
        "Action": "codedeploy:CreateDeployment",
        "Resource": "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentgroup:${aws_codedeploy_app.webapp.name}/${aws_codedeploy_deployment_group.deploy_group.deployment_group_name}"
    },
    {
        "Sid": "2",
        "Effect": "Allow",
        "Action": "codedeploy:GetDeployment",
        "Resource": "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentgroup:${aws_codedeploy_app.webapp.name}/${aws_codedeploy_deployment_group.deploy_group.deployment_group_name}"
    },
    {
        "Sid": "3",
        "Effect": "Allow",
        "Action": "codedeploy:RegisterApplicationRevision",
        "Resource": "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application:${aws_codedeploy_app.webapp.name}"
    },
    {
        "Sid": "4",
        "Effect": "Allow",
        "Action": "codedeploy:GetDeploymentConfig",
        "Resource": "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime"
    },
    {
        "Sid": "5",
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "${aws_s3_bucket.deployment_artifacts.arn}"
    },
    {
        "Sid": "6",
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "${aws_s3_bucket.deployment_artifacts.arn}/*"
    }
]
}
EOF
}