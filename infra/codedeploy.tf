resource "aws_s3_bucket" "deployment_artifacts" {
  bucket = "aws-codedeploy-chef-demo"
}

resource "aws_codedeploy_app" "webapp" {
  compute_platform = "Server"
  name             = "webapp"
}

resource "aws_iam_role" "codedeploy" {
  name = "codedeploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = "${aws_iam_role.codedeploy.name}"
}

resource "aws_codedeploy_deployment_group" "deploy_group" {
  app_name              = "${aws_codedeploy_app.webapp.name}"
  deployment_group_name = "webapp-test"
  service_role_arn      = "${aws_iam_role.codedeploy.arn}"
  autoscaling_groups = ["${aws_autoscaling_group.webapp.name}"]
}