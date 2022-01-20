
variable "external_id" {
  description = "External ID for the OtterTune role. Copy from OtterTune role setup wizard."
  type = string
}

variable "iam_role_name" {
  description = "Role Name for the OtterTune role. This name can be whatever you like."
  type    = string
  default = "OtterTuneRole"
}

variable "tunable_parameter_group_arns" {
  description = <<- EOT
                    Pass in the parameter group ARNs that you would like to allow OtterTune to optimize. 
                    Leave blank if you would like to run OtterTune in monitoring-only mode for now. This can be updated later.
                    ARN Format: arn:aws:rds:<region>:<account>:pg:<name>. 
                    EOT
  type    = list(string)
  default = []
}

# 
variable "tunable_aurora_cluster_parameter_group_arns" {
  description = <<- EOT
                    Pass in the aurora cluster parameter group ARNs that you would like to allow OtterTune to optimize. 
                    Leave blank if you would like to run OtterTune in monitoring-only mode for now. This can be updated later.
                    ARN Format: arn:aws:rds:<region>:<account>:pg:<name>
                    EOT
  type    = list(string)
  default = []
}

variable "ottertune_account_id" {
  description = "OtterTune Account ID, exposed to help terraform readability, no need to modify."
  type    = string
  default = "691523222388"
}
