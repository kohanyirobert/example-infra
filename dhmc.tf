# Enables default host management configuration in SSM, the following module does the same and more:
# https://github.com/hashicorp/terraform-provider-aws/issues/30474#issuecomment-1906150269
data "aws_iam_policy" "ssm_managed_ec2_instance_default" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

module "ssm_default_host_management_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.48.0"

  create_role = true

  trusted_role_services = [
    "ssm.amazonaws.com"
  ]

  role_name         = "AWSSystemsManagerDefaultEC2InstanceManagementRole"
  role_path         = "/service-role/"
  role_requires_mfa = false

  custom_role_policy_arns = [data.aws_iam_policy.ssm_managed_ec2_instance_default.arn]
}

resource "aws_ssm_service_setting" "default_host_management" {
  setting_id    = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = trimprefix("${module.ssm_default_host_management_role.iam_role_path}${module.ssm_default_host_management_role.iam_role_name}", "/")
}
