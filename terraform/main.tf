module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "3tier"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  iam_role_arn = aws_iam_role.eks_cluster_role.arn

  enable_irsa = true

  eks_managed_node_groups = {} # Required even if using Fargate only

  fargate_profiles = {
    app = {
      name = "app"
      selectors = [
        {
          namespace = "3tier-demo"
        }
      ]
    }
  }

  tags = {
    Environment = "dev"
    Project     = "3tier"
  }
}





# Export kubeconfig data for providers
data "aws_eks_cluster" "cluster" {
name = module.eks.cluster_id
}


data "aws_eks_cluster_auth" "cluster" {
name = module.eks.cluster_id
}


provider "kubernetes" {
host = data.aws_eks_cluster.cluster.endpoint
cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
token = data.aws_eks_cluster_auth.cluster.token
}


provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


# Create namespace
resource "kubernetes_namespace" "app_ns" {
metadata {
name = "3tier-demo"
}
}