resource "aws_efs_file_system" "efs" {
  creation_token = "3tier-efs-${var.cluster_name}"

  tags = {
    Name = "3tier-efs"
  }
}

# Create mount targets for each private subnet created by the VPC module
locals {
  target_subnet_map = {
    subnet_1 = module.vpc.private_subnets[0]
    subnet_2 = module.vpc.private_subnets[1]
    subnet_3 = module.vpc.private_subnets[2]
  }
}

resource "aws_efs_mount_target" "mt" {
  for_each = local.target_subnet_map

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [module.eks.cluster_security_group_id]
}
