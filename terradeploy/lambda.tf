resource "random_pet" "lambda_name" {
  length = 2
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = random_pet.lambda_name.id
  description   = "Named Entity Recognition Model"
  handler       = "model.predict"
  runtime       = "python3.8"

  source_path = "${path.module}"

  vpc_subnet_ids         = module.vpc.intra_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  attach_network_policy  = true

  file_system_arn              = aws_efs_access_point.lambda.arn
  file_system_local_mount_path = "/mnt/shared-storage"

  tags = {
    Name        = "machine-learning" # tags are important for cost tracking
    Environment = "prod"
  }

  depends_on = [aws_efs_mount_target.model_target]
}

