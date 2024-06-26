# Terraform AWS Elastic Beanstalk NodeJS

Terraform script to setup AWS Elastic Beanstalk with a load-balanced NodeJS app

## What this script does

* Create an Elastic Beanstalk Application and environment.
* Setup the EB environment with NodeJS, an Elastic Loadbalancer and forward port from HTTP / HTTPS to the specified instance port.


## Usage

Create a `.tf` file with the following configuration:

### Create an EB environment

```hcl
##################################################
## Your variables
##################################################
variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}
variable "service_name" {
  type    = "string"
  default = "nodejs-app-test"
}
variable "service_description" {
  type    = "string"
  default = "My awesome nodeJs App"
}
##################################################
## AWS config
##################################################
provider "aws" {
  region = "${var.aws_region}"
}

##################################################
## Elastic Beanstalk config
##################################################
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${var.service_name}"
  description = "${var.service_description}"
}

module "eb_env" {
  source = "github.com/MIT-45/terraform-modules//elastic-beanstalk-nodejs"
  aws_region = "${var.aws_region}"

  # Application settings
  service_name = "nodejs-app-test"
  service_description = "My awesome nodeJs App"
  env = "dev"

  # Instance settings
  instance_type = "t2.micro"
  min_instance = "2"
  max_instance = "4"

  # ELB
  enable_https = "false" # If set to true, you will need to add an ssl_certificate_id (see L70 in app/variables.tf)

  # Security
  vpc_id = "vpc-xxxxxxx"
  vpc_subnets = "subnet-xxxxxxx"
  elb_subnets = "subnet-xxxxxxx"
  security_groups = "sg-xxxxxxx"
}
```

### Add an Elastic File System to your EB

* First, create the EFS before the Elastic Beanstalk Environment:
```hcl
##################################################
## AWS Elastic File System
##################################################
resource "aws_efs_file_system" "file_storage" {
  creation_token = "${var.service_name}-${var.env}"

  tags {
    Name = "${var.service_name}-${var.env}"
  }
}

resource "aws_efs_mount_target" "file_storage_target" {
  file_system_id  = "${aws_efs_file_system.file_storage.id}"
  subnet_id       = "${var.vpc_subnets}"
  security_groups = ["${var.security_groups}"]
}
```

* Then set `efs_id` & `efs_mount_directory` to the Elastic Beanstalk Environment module:
```hcl
##################################################
## Elastic Beanstalk config
##################################################
module "eb_env" {
   source       = "github.com/MIT-45/terraform-modules//elastic-beanstalk-nodejs"
  
    # Application settings
    service_name          = "nodejs-app-test"
    service_description   = "My awesome nodeJs App"
    env                   = "dev"
  
    # Instance settings
    instance_type = "t2.micro"
    min_instance  = "2"
    max_instance  = "4"
  
    # ELB
    enable_https  = "false" # If set to true, you will need to add an ssl_certificate_id (see L70 in app/variables.tf)
  
    # Security
    vpc_id            = "vpc-xxxxxxx"
    vpc_subnets       = "subnet-xxxxxxx"
    elb_subnets       = "subnet-xxxxxxx"
    security_groups   = "sg-xxxxxxx"
  
    # EFS
    efs_id                = "${aws_efs_file_system.file_storage.id}"
    efs_mount_directory   = "/var/app/efs"
}
```

* Finally, copy `efs_mount.config` to your `.ebextensions` project directory and deploy using AWS EB CLI


## Customize

Many options are available through variables. Feel free to look into `variables.tf` inside each module to see all parameters you can setup.

## Terraform related documentation

* Elastic Beanstalk Application: https://www.terraform.io/docs/providers/aws/r/elastic_beanstalk_application.html
* Elastic Beanstalk Environment: https://www.terraform.io/docs/providers/aws/r/elastic_beanstalk_environment.html