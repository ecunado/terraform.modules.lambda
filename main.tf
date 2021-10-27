##########
# IAM
##########
resource "aws_iam_role" "lambda_iam_role" {
  name               = var.iam_role_name
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_instance_profile" "lambda_instance_profile" {
  name   = aws_iam_role.lambda_iam_role.name
  role   = aws_iam_role.lambda_iam_role.name
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name    = var.lambda_function_name
  role    = aws_iam_role.lambda_iam_role.id
  policy  = var.iam_role_policy
}

resource "aws_iam_role_policy_attachment" "attached_policies" {
  count      = length(var.attached_policies_arn)
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = element(var.attached_policies_arn,count.index)
}

##########
# Lambda
##########
resource "aws_lambda_function" "lambda" {
  count             = var.attach_vpc_config == "false" ? 1 : 0
  filename          = var.lambda_filename
  function_name     = var.lambda_function_name
  role              = aws_iam_role.lambda_iam_role.arn
  handler           = var.lambda_handler
  source_code_hash  = var.lambda_sourcecode_hash
  runtime           = var.lambda_runtime
  timeout           = var.lambda_timeout
  memory_size       = var.lambda_memory_size
  tags              = var.lambda_tags
  layers            = var.lambda_layers
  environment {
    variables = var.lambda_variables
  }
}

resource "aws_lambda_function" "lambda_with_vpc" {
  count             = var.attach_vpc_config == "true" ? 1 : 0
  filename          = var.lambda_filename
  function_name     = var.lambda_function_name
  role              = aws_iam_role.lambda_iam_role.arn
  handler           = var.lambda_handler
  source_code_hash  = var.lambda_sourcecode_hash
  runtime           = var.lambda_runtime
  timeout           = var.lambda_timeout
  memory_size       = var.lambda_memory_size
  layers            = var.lambda_layers
  vpc_config {
    security_group_ids = var.vpc_config["security_group_ids"]
    subnet_ids         = var.vpc_config["subnet_ids"]
  }
  tags              = var.lambda_tags

  environment {
    variables = var.lambda_variables
  }
}

####################
# Cloudwatch event #
####################
resource "aws_cloudwatch_event_rule" "lambda_cron_event_rule" {
  count               = var.cloudwatch_schedule_expression != "" ? 1 : 0
  name                = var.lambda_function_name
  description         = "Schedule Event for ${var.lambda_function_name} lambda function"
  schedule_expression = var.cloudwatch_schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_cron_event_target" {
  count      = var.cloudwatch_schedule_expression != "" && var.attach_vpc_config == "false" ? 1 : 0
  rule       = aws_cloudwatch_event_rule.lambda_cron_event_rule[count.index].name
  arn        = aws_lambda_function.lambda[count.index].arn
}

resource "aws_cloudwatch_event_target" "lambda_cron_event_target_with_vpc" {
  count      = var.cloudwatch_schedule_expression != "" && var.attach_vpc_config == "true" ? 1 : 0
  rule       = aws_cloudwatch_event_rule.lambda_cron_event_rule[count.index].name
  arn        = aws_lambda_function.lambda_with_vpc[count.index].arn
}

#########################
# Cloudwatch permission #
#########################
resource "aws_lambda_permission" "lambda_cron_cloudwatch_permission" {
  count         = var.cloudwatch_schedule_expression != "" ? 1 : 0
  statement_id  = md5(var.lambda_function_name)
  action        = var.lambda_permission_action
  function_name = var.lambda_function_name
  principal     = var.lambda_permission_principal
  source_arn    = aws_cloudwatch_event_rule.lambda_cron_event_rule[count.index].arn
  depends_on    = [aws_lambda_function.lambda_with_vpc,aws_lambda_function.lambda]
}
