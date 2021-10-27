output "lambda_arn" { value = element(concat(aws_lambda_function.lambda.*.arn, aws_lambda_function.lambda_with_vpc.*.arn,tolist([""])), 0) }
