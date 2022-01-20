
# External ID for the OtterTune role. Copy from OtterTune role setup wizard.
variable "external_id" {
  type = string
}

# Role Name for the OtterTune role. This name can be whatever you like.```
variable "iam_role_name" {
  type = string
  default = "OtterTuneRole"
}

# Pass in the parameter group ARNs that you'd like to allow OtterTune to optimize. 
# Leave blank if you would like to run OtterTune in monitoring-only mode for now. This can be updated later.
# ARN Format: arn:aws:rds:<region>:<account>:pg:<name>
variable "tunable_parameter_group_arns" {
  type = list(string)
  default = []
}

# Pass in the aurora cluster parameter group ARNs that you'd like to allow OtterTune to optimize. 
# Leave blank if you would like to run OtterTune in monitoring-only mode for now. This can be updated later.
# ARN Format: arn:aws:rds:<region>:<account>:pg:<name>
variable "tunable_aurora_cluster_parameter_group_arns" {
  type = list(string)
  default = []
}

variable "ottertune_account_id" {
  type = string
  default = "691523222388"
}
