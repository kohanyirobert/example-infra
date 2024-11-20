data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ec2_create_tag" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_create_tag" {
  name   = "AllowEC2CreateTags"
  policy = data.aws_iam_policy_document.ec2_create_tag.json

  tags = {
    Project = var.project
  }
}

data "aws_iam_policy_document" "ssm_db_password" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${aws_ssm_parameter.db_password.name}"]
  }
}

resource "aws_iam_policy" "ssm_db_password" {
  name   = "AllowSSMDbPassword"
  policy = data.aws_iam_policy_document.ssm_db_password.json

  tags = {
    Project = var.project
  }
}

resource "aws_iam_role" "ready_tagger_and_ssm_db_password" {
  name               = "ReadyTaggerAndSSMDbPasswordRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Project = var.project
  }
}

resource "aws_iam_instance_profile" "ready_tagger_and_ssm_db_password" {
  name = "ReadyTaggerAndSSMDbPasswordInstanceProfile"
  role = aws_iam_role.ready_tagger_and_ssm_db_password.name

  tags = {
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ssm_db_password" {
  role       = aws_iam_role.ready_tagger_and_ssm_db_password.name
  policy_arn = aws_iam_policy.ssm_db_password.arn
}


resource "aws_iam_role_policy_attachment" "ec2_create_tag" {
  role       = aws_iam_role.ready_tagger_and_ssm_db_password.name
  policy_arn = aws_iam_policy.ec2_create_tag.arn
}

resource "aws_iam_role" "ready_tagger_only" {
  name               = "ReadyTaggerOnlyRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Project = var.project
  }
}

resource "aws_iam_instance_profile" "ready_tagger_only" {
  name = "ReadyTaggerOnlyInstanceProfile"
  role = aws_iam_role.ready_tagger_only.name

  tags = {
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ready_tagger_only" {
  role       = aws_iam_role.ready_tagger_only.name
  policy_arn = aws_iam_policy.ec2_create_tag.arn
}
