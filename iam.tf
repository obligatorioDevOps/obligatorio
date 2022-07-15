# Global

module "iam_account" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-account"
  version = "~> 4.3"

  account_alias = var.project_name

  minimum_password_length = 12
  max_password_age = 30
  password_reuse_prevention = 5
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_symbols = true
  require_numbers         = true

}



data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

 





