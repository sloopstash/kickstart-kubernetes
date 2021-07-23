output "s3_osw_chef_bkt_name" {
  depends_on = [aws_s3_bucket.s3_osw_chef_bkt]
  value = aws_s3_bucket.s3_osw_chef_bkt.id
}
