module "kms" {
  source = "../.."

  deletion_window = 10
  identifier      = "simple-example"
  tags            = var.tags
}
