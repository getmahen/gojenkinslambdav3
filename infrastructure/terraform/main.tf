resource "aws_lambda_function" "jenkinsgolambda" {
  s3_bucket     = "${data.aws_s3_bucket_object.jenkinsgolambda_pkg.bucket}"//"testjenkinsartifacts"
  s3_key        = "${data.aws_s3_bucket_object.jenkinsgolambda_pkg.key}"//"jenkinsgolambda.zip"
  s3_object_version = "${data.aws_s3_bucket_object.jenkinsgolambda_pkg.version_id}"
  function_name = "jenkinsgolambda"
  runtime       = "go1.x"
  handler       = "jenkinsgolambda"
  role          = "${aws_iam_role.jenkinsgolambda_role.arn}"
  timeout       = 10
  description   = "Test Go Lambda function that outputs IP address"
  publish       = false


resource "aws_iam_role" "jenkinsgolambda_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

//ALIAS for Lambda
# resource "aws_lambda_alias" "jenkinsgolambda_alias" {
#   name             = "jenkinsgolambdaalias"
#   description      = "a sample description"
#   function_name    = "${aws_lambda_function.jenkinsgolambda.arn}"
#   function_version = "1"//"${data.aws_lambda_function.jenkinsgolambda_data.version}"//"1"
#   # routing_config   = {
#   #   additional_version_weights = {
#   #     "2" = 0.5
#   #   }
#   # }
# }