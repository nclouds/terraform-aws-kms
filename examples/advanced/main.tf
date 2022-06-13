module "kms" {
  source = "../.."

  deletion_window = 10
  enable_alias    = true
  description     = "my testing kms key"
  identifier      = "simple-example"
  tags            = var.tags
}
