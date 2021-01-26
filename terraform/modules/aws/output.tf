output "stg_ec2_master_sr_1_pub_ip" {
  depends_on = [aws_instance.stg_ec2_master_sr_1]
  value = aws_instance.stg_ec2_master_sr_1.public_ip
}
output "stg_ec2_worker_sr_1_pub_ip" {
  depends_on = [aws_instance.stg_ec2_worker_sr_1]
  value = aws_instance.stg_ec2_worker_sr_1.public_ip
}
