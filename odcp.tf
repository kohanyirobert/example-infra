resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    # NOTE: thumbprint required, but ignored: https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#configuring-iam-to-trust-github
    "ffffffffffffffffffffffffffffffffffffffff"
  ]

  tags = {
    Project = var.project
  }
}

data "aws_iam_policy_document" "github_actions_oidc_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn,
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_oidc_subject}"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "github_actions_terraform_automation" {
  name               = "GitHubActionsTerraformAutomationRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_assume_role.json
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.github_actions_terraform_automation.name
  policy_arn = data.aws_iam_policy.s3_full_access.arn
}

data "aws_iam_policy" "ec2_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.github_actions_terraform_automation.name
  policy_arn = data.aws_iam_policy.ec2_full_access.arn
}

data "aws_iam_policy" "ssm_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_full_access" {
  role       = aws_iam_role.github_actions_terraform_automation.name
  policy_arn = data.aws_iam_policy.ssm_full_access.arn
}

data "aws_iam_policy" "iam_full_access" {
  arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_full_access" {
  role       = aws_iam_role.github_actions_terraform_automation.name
  policy_arn = data.aws_iam_policy.iam_full_access.arn
}

data "aws_iam_policy" "dynamodb_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.github_actions_terraform_automation.name
  policy_arn = data.aws_iam_policy.dynamodb_full_access.arn
}

data "aws_iam_policy" "route53_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "route53_full_access" {
  role       = aws_iam_role.github_actions_terraform_automation.name
  policy_arn = data.aws_iam_policy.route53_full_access.arn
}
