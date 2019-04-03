# Demo project: Codeship Pro + AWS CodeDeploy + Docker + Chef

This is a demo project demonstrating and making use of the following:

- CodeShip Pro
- AWS CodeDeploy + Docker
- Chef
- Terraform

We will be deploying a demo web application (written in Golang, but that doesn't matter) as
a docker container using CodeShip Pro's native integration with AWS CodeDeploy. Instead of
writing shell scripts (Bash, Powershell), we will be using [chef](https://www.chef.io/configuration-management/) cookbooks to deploy
our application.

The sub-directories in this repo are described next.

## chef

The cookbook for deploying the web application is stored here. It also contains a `Berksfile`
specifying the cookbook dependencies. The [./build_chef.sh](./build_chef.sh) script "vendors"
these dependencies based on the `Berksfile`, creates a zip file and uploads it to S3.

The [solo.rb](./chef/solo.rb) file contains the configuration for `chef-solo`.

## infra

This directory contains the Terraform configuration for configuring the AWS infrastructure:

- `asg.tf`: Configures the Autoscaling group, launch configuration, VPC, subnets and security group
- `codedeploy.tf`: Configures the Codedeploy deployment application, deployment group, S3
bucket for storing the build artifacts and required IAM policies
- `codedeploy_user.tf`: Configures the IAM user and creates appropriate IAM policies to
deploy the web application from CodeShip pro.
- `data/user_data.txt`: This specifies the user data for the EC2 instances launched via the
autoscaling group. We use the user data script to install AWS codedeploy agent, 
`chef` workstation and other utilities.

The terraform tfstate file is also version controlled for the purposes of this demo, but
should be configured to use remote state instead.

## webapp

This diretory contains the source code for our web application, the `Dockerfile` for building
the docker image and the AWS codedeploy specific files in the `deployment/` sub-directory.

## devsetup

This directory contains Terraform configuration for setting up a Linux AWS lightsail instance
which may be useful for setting up your project. We use user data script to install 
`docker` and jet CLI. Since the terraform configuration will create a AWS Key pair for
SSH-ing into your instance, it will output the SSH private key when you apply the terraform
configuration. Save it to a local file and use that to SSH into your instance. Hence,
the state file is explicitly ignored in `.gitignore`. By default, the AWS lightsail instance
will allow connections on port 22 from any IPs, so, be mindful of this.

# LICENSE

MIT