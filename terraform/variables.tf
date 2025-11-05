variable "region" {
type = string
default = "us-east-2"
}




variable "cluster_name" {
type = string
default = "3tier-eks-fargate"
}


# variable "vpc_id" {
# type = string
# default = "" # optional: provide to use existing VPC
# }


# variable "public_subnets" {
# type = list(string)
# default = ["pub-subnet-eks-1", "pub-subnet-eks-2"]
# }


# variable "private_subnets" {
# type = list(string)
# default = ["private-subnet-eks-1", "private-subnet-eks-2"]
# }


