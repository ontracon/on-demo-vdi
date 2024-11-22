# ---------------------------------------------------------------------------------------------------------------------
# Global Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "cloud_region" {
  type        = string
  description = "Define the cloud region to use (AWS Region / Azure Location / GCP region) which tf should use."
}

variable "config" {
  type = object({
    prefix       = string
    environment  = string
    application  = string
    productive   = optional(bool, false)
    customer     = optional(string, "")
    businessunit = optional(string, "")
    project      = optional(string, "")
    costcenter   = optional(string, "")
    owner        = optional(string, "")
  })
  description = "Global config Object which contains the mandatory information's for deploying resources to ensure tagging."
}


# ---------------------------------------------------------------------------------------------------------------------
# Custom Variables
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Module variables
# ---------------------------------------------------------------------------------------------------------------------
variable "enabled" {
  type        = bool
  default     = true
  description = "Enables this Blueprint."
}


variable "aws_domain_name" {
  description = "The Route53 Zone used for the dns entries. This must already exist in the AWS account. (e.g dev.kasm.contoso.com). The deployment will be accessed via this zone name via https"
  type        = string
}

variable "num_webapps" {
  description = "The number of WebApp role servers to create in the deployment"
  type        = number
  default     = 2
}

variable "num_agents" {
  description = "The number of Agent Role Servers to create in the deployment"
  type        = number
  default     = 2
}

variable "num_cpx_nodes" {
  description = "The number of cpx RDP Role Servers to create in the deployment"
  type        = number
  default     = 2
}


variable "webapp_hdd_size_gb" {
  description = "The HDD size for Kasm Webapp nodes"
  type        = number
}

variable "db_hdd_size_gb" {
  description = "The HDD size for Kasm DB"
  type        = number
}

variable "cpx_hdd_size_gb" {
  description = "The HDD size for Kasm Guac RDP nodes"
  type        = number
}

variable "agent_hdd_size_gb" {
  description = "The HDD size for Kasm Agent nodes"
  type        = number
}

variable "ec2_ami" {
  description = "The AMI used for the EC2 nodes. Recommended Ubuntu 20.04 LTS."
  type        = string
}

variable "kasm_build" {
  description = "The URL for the Kasm Workspaces build"
  type        = string
}

variable "swap_size" {
  description = "The amount of swap (in GB) to configure inside the compute instances"
  type        = number
}

variable "create_aws_ssm_iam_role" {
  description = "Create an AWS SSM IAM role to attach to VMs for SSH/console access to VMs."
  type        = bool
  default     = false
}

variable "admin_password" {
  description = "The administrative user password. No special characters"
  type        = string
  sensitive   = true
}


variable "anywhere" {
  description = "Anywhere route subnet"
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.anywhere, 0))
    error_message = "Anywhere variable must be valid IPv4 CIDR - usually 0.0.0.0/0 for all default routes and default Security Group access."
  }
}

variable "ssh_authorized_keys" {
  description = "The SSH Public Keys to be installed on the compute instances"
  type        = string
}

