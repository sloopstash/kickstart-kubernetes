output "stg_ec2_k8s_mtr_1_pub_ip" {
  depends_on = [aws_instance.stg_ec2_k8s_mtr_1]
  value = aws_instance.stg_ec2_k8s_mtr_1.public_ip
}
output "stg_ec2_k8s_wkr_1_pub_ip" {
  depends_on = [aws_instance.stg_ec2_k8s_wkr_1]
  value = aws_instance.stg_ec2_k8s_wkr_1.public_ip
}
