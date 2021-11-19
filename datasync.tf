resource "aws_datasync_location_s3" "s3_loc" {
  s3_bucket_arn = "arn" # copy the bucket arn you created in the previous step
}

resource "aws_datasync_location_efs" "efs_loc" {
  efs_file_system_arn = aws_efs_mount_target.model_target.file_system_arn

  ec2_config {
    security_group_arns = [module.vpc.default_security_group_id]
    subnet_arn          = module.vpc.intra_subnets[0]
  }
}

resource "aws_datasync_task" "model_sync" {
  name                     = "named-entity-model-sync-job"
  destination_location_arn = aws_datasync_location_s3.efs_loc.arn
  source_location_arn      = aws_datasync_location_nfs.s3_loc.arn

  options {
    bytes_per_second = -1
  }

  tags = {
    Name        = "machine-learning" # tags are important for cost tracking
    Environment = "prod"
  }
}
