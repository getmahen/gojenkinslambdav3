data "aws_s3_bucket_object" "jenkinsgolambda_pkg" {
  bucket = "testjenkinsartifacts"
  key    = "jenkinsgolambda.zip"
}

data "aws_lambda_function" "jenkinsgolambda_data" {
  function_name = "jenkinsgolambda"
}
