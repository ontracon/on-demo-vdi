provider "aws" {
  region = var.cloud_region
}

resource "random_password" "this" {
  for_each = toset(["admin", "user", "token", "redis", "manager"])
  length   = 20
  special  = false
}

module "dev_vdi" {
  count                      = var.enabled ? 1 : 0
  source                     = "git::https://github.com/otc-code/blue-aws-kasm.git?ref=v1.0.0"
  cloud_region               = var.cloud_region
  config                     = var.config
  project_name               = join("-", [var.config.prefix, var.config.environment, var.config.application])
  num_webapps                = var.num_webapps
  num_agents                 = var.num_agents
  num_cpx_nodes              = var.num_cpx_nodes
  aws_domain_name            = var.aws_domain_name
  manager_token              = random_password.this["manager"].result
  database_password          = random_password.this["redis"].result
  redis_password             = random_password.this["redis"].result
  admin_password             = var.admin_password
  user_password              = random_password.this["user"].result
  service_registration_token = random_password.this["token"].result
  ssh_authorized_keys        = var.ssh_authorized_keys
  kasm_build                 = var.kasm_build
  db_hdd_size_gb             = var.db_hdd_size_gb
  webapp_hdd_size_gb         = var.webapp_hdd_size_gb
  cpx_hdd_size_gb            = var.cpx_hdd_size_gb
  agent_hdd_size_gb          = var.agent_hdd_size_gb
  swap_size                  = var.swap_size
  ec2_ami                    = var.ec2_ami
  create_aws_ssm_iam_role    = var.create_aws_ssm_iam_role
}
