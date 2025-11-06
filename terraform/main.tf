module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true


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

  eks_managed_node_groups = {
    alb_controller = {
      desired_capacity     = 1
      max_capacity         = 1
      min_capacity         = 1
      instance_types       = ["t3.small"]
      subnet_ids           = module.vpc.public_subnets
      node_group_name      = "alb-controller"
      node_group_public_ip = true # <-- assign public IPs
      labels = {
        role = "alb-controller"
      }
      tags = {
        Project = "3tier"
      }
    }
  } # Required even if using Fargate only

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = false
  enable_cluster_creator_admin_permissions = true

  fargate_profiles = {
    app = {

      name = "app"
      selectors = [
        {
          namespace = "3tier-demo"
        }
      ]
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Environment = "dev"
    Project     = "3tier"
  }
}


# Export kubeconfig data for providers
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }

  # This forces dependency on EKS creation
  alias = "eks"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


# Create namespace
resource "kubernetes_namespace" "app_ns" {
  provider = kubernetes.eks
  metadata {
    name = "3tier-demo"
  }
}
