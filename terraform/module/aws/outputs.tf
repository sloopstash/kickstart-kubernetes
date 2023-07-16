output "ec2_nat_sr_1_pub_ip" {
  depends_on = [aws_instance.ec2_nat_sr_1]
  value = aws_instance.ec2_nat_sr_1.public_ip
}
output "eks_ct_endpoint" {
  depends_on = [aws_eks_cluster.eks_ct]
  value = aws_eks_cluster.eks_ct.endpoint
}
