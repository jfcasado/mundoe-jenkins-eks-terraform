module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.24"
  
  #Cluster Networks
  vpc_id          = module.mundose-vpc.vpc_id
  subnet_ids     = module.mundose-vpc.private_subnets

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  eks_managed_node_group_defaults = {
    root_volume_type = "gp2"
    instance_types = ["t2.small"]
  }
  eks_managed_node_groups = {
    one = {
      name                    = "worker-group-1"
      instance_type           = "t2.small"
      min_size = 1
      max_size = 3      
      desired_size            = 2
      pre_bootstrap_user_data = <<-EOT
      echo 'foo bar'
      EOT
       vpc_security_group_ids = [aws_security_group.worker_group_mgmt_one.id ]
    }

    #two = {
    #  name                    = "worker-group-2"
    #  instance_type           = "t2.medium"
    #  desired_size            = 1
    #  pre_bootstrap_user_data = <<-EOT
    #  echo 'foo bar'
    #  EOT
    #   vpc_security_group_ids = [aws_security_group.worker_group_mgmt_two.id] ]
    #}
  }
}
  
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
