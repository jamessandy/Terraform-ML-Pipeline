resource "random_pet" "vpc_name" {
  length = 2
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = random_pet.vpc_name.id
  cidr = "10.10.0.0/16"

  azs           = ["us-east-1"]
  intra_subnets = ["10.10.101.0/24"]

  tags = {
    Name        = "machine-learning" # tags are important for cost tracking
    Environment = "prod"
  }

}

resource "aws_efs_file_system" "model_efs" {}

resource "aws_efs_mount_target" "model_target" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = module.vpc.intra_subnets[0]
  security_groups = [module.vpc.default_security_group_id]

  tags = {
    Name        = "machine-learning" # tags are important for cost tracking
    Environment = "prod"
  }

}

resource "aws_efs_access_point" "lambda_ap" {
  file_system_id = aws_efs_file_system.shared.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/lambda"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0777"
    }
  }

  tags = {
    Name        = "machine-learning" # tags are important for cost tracking
    Environment = "prod"
  }
}
