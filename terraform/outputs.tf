output "cluster_id" {
value = module.eks.cluster_id
}


output "kubeconfig" {
  value     = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.cluster.certificate_authority[0].data}
  name: ${var.cluster_name}
contexts:
- context:
    cluster: ${var.cluster_name}
    user: ${var.cluster_name}
  name: ${var.cluster_name}
current-context: ${var.cluster_name}
kind: Config
preferences: {}
users:
- name: ${var.cluster_name}
  user:
    token: ${data.aws_eks_cluster_auth.cluster.token}
EOT
  sensitive = true
}

output "alb_hostname" {
 value = helm_release.aws_lb_controller.status
description = "ALB hostname (may take several minutes to become available)"
depends_on = [helm_release.aws_lb_controller]
}


output "efs_id" {
value = aws_efs_file_system.efs.id
}


