provider "aws" {
  region = "us-west-2"

  assume_role {
    //role_arn = "arn:aws:iam::${lookup(var.env_to_acct_id, var.environment)}:role/terraform"
    role_arn = "${var.terraform_user == "jenkins" ? local.jenkins_role : local.terraform_role}"
  }
}

locals {
  jenkins_role = "arn:aws:iam::${lookup(var.env_to_acct_id, var.environment)}:role/jenkins/jenkins_env"
  terraform_role = "arn:aws:iam::${lookup(var.env_to_acct_id, var.environment)}:role/terraform"
}

variable "env_to_acct_id" {
  type = "map"

  default = {
    dev = "674346455231"
    qa  = "772404289823"
  }
}
