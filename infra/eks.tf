module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = [module.vpc.private_subnets[0], module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  tags = {
    Environment = "dev"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group"
      instance_type                 = "t3.small"
      additional_userdata           = "echo Worker group 1 init successful"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo Worker group 2 init successful"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
