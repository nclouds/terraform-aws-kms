locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)
}

resource "aws_kms_key" "key" {
  deletion_window_in_days = var.deletion_window
  enable_key_rotation     = var.enable_key_rotation
  description             = var.description == null ? "KMS key for ${local.identifier}" : var.description
  policy                  = var.policy
  tags                    = local.tags
}

resource "aws_kms_alias" "a" {
  count = var.enable_alias ? 1 : 0

  target_key_id = aws_kms_key.key.key_id
  name          = "alias/${local.identifier}"
}
