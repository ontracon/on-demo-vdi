enabled=true
cloud_region = "eu-central-1"
config = {
  prefix      = "on"
  environment = "dev"
  application = "vdi"
}
aws_domain_name            = "vdi.dev.ontracon.cloud"
admin_password             = "MySecretPassword"
num_webapps=1
num_agents=1
num_cpx_nodes=1

ssh_authorized_keys        = ""
kasm_build                 = "https://kasm-static-content.s3.amazonaws.com/kasm_release_1.16.1.6efdbd.tar.gz"
db_hdd_size_gb             = 50
webapp_hdd_size_gb         = 50
cpx_hdd_size_gb            = 50
agent_hdd_size_gb          = 50
swap_size                  = 10
ec2_ami                    = "ami-0745b7d4092315796" # Ubuntu 22.04
create_aws_ssm_iam_role    = true
