output "s3_osw_chef_bkt_name" {
  depends_on = [aws_s3_bucket.s3_osw_chef_bkt]
  value = aws_s3_bucket.s3_osw_chef_bkt.id
}
output "ec2_nat_sr_1_pub_ip" {
  depends_on = [aws_instance.ec2_nat_sr_1]
  value = aws_instance.ec2_nat_sr_1.public_ip
}
