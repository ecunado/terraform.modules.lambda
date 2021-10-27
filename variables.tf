variable "iam_role_name"              { }
variable "assume_role_policy"         { }
variable "iam_role_policy"            { }
variable "attached_policies_arn"      {
                                        type = list
                                        default = []
                                      }
variable "lambda_function_name"       { }
variable "lambda_filename"            { }
variable "lambda_handler"             { }
variable "lambda_runtime"             { default = "python3.8" }
variable "lambda_timeout"             { default = "30" }
variable "lambda_variables"           {
                                        type = map
                                        default = {}
                                      }
variable "lambda_tags"                {
                                        type = map
                                        default = {}
                                      }
variable "lambda_sourcecode_hash"     { }
variable "vpc_config"                 {
                                        type = map
                                        default = {}
                                      }
variable "attach_vpc_config"          {
                                        type = string
                                        default = "false"
                                      }
variable "log_retention_days"         { default = 365 }
variable "lambda_memory_size"         { default = 128 }
variable "lambda_layers"              {
                                        type = list
                                        default = []
                                      }

# Cloudwatch (optional)
variable "cloudwatch_schedule_expression"   { default = "" }
variable "lambda_permission_principal"      { default = "events.amazonaws.com" }
variable "lambda_permission_action"         { default = "lambda:InvokeFunction" }