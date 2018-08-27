output "lambda_arn" {
  value = "${aws_lambda_function.jenkinsgolambda.arn}"
}

output "lambda_function_name" {
  value = "${aws_lambda_function.jenkinsgolambda.function_name}"
}

output "lambda_function_version" {
  value = "${aws_lambda_function.jenkinsgolambda.version}"
}

output "lambda_function_version_metadata" {
  value = "${data.aws_s3_bucket_object.jenkinsgolambda_pkg.metadata}"
}
