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

variable "dcl" {
  type = object({
    integrity       = optional(string, "normal")
    confidentiality = optional(string, "normal")
    availability    = optional(string, "normal")
  })
  default = {
    integrity       = "normal"
    confidentiality = "normal"
    availability    = "normal"
  }
  description = <<EOT
Data classification to determine protection class (normal, high, very_high) based on:
- Integrity: The information is reliable and cannot be manipulated.
- Confidentiality: Only authorized persons have access to the information.
- Availability: Information is available at the times requested.

Base coverage is not complete, but is a first step. Only when you have reached the next level of standard protection are all topics for the category of normal protection needs covered.
EOT
}

# variable "names_override_file" {
#   type        = string
#   default     = null
#   description = "Override automatic naming with a json template file."
# }

# ---------------------------------------------------------------------------------------------------------------------
# Custom Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "custom_tags" {
  type        = map(string)
  default     = null
  description = "A map of custom tags."
}

variable "custom_name" {
  type        = string
  default     = ""
  description = "Set custom name for deployment."
}

# ---------------------------------------------------------------------------------------------------------------------
# Module variables
# ---------------------------------------------------------------------------------------------------------------------
variable "enabled" {
  type        = bool
  default     = true
  description = "Enables this Blueprint."
}

variable "project_name" {
  description = "The name of the deployment (e.g dev, staging). A short single word"
  type        = string
}

variable "aws_domain_name" {
  description = "The Route53 Zone used for the dns entries. This must already exist in the AWS account. (e.g dev.kasm.contoso.com). The deployment will be accessed via this zone name via https"
  type        = string
}

variable "vpc_subnet_cidr" {
  description = "The subnet CIDR to use for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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

variable "webapp_instance_type" {
  description = "The instance type for the webapps"
  type        = string
  default     = "t3.small"
}

variable "db_instance_type" {
  description = "The instance type for the Database"
  type        = string
  default     = "t3.small"
}

variable "agent_instance_type" {
  description = "The instance type for the Agents"
  type        = string
  default     = "t3.medium"
}

variable "cpx_instance_type" {
  description = "The instance type for the cpxamole RDP nodes"
  type        = string
  default     = "t3.medium"
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

variable "web_access_cidrs" {
  description = "CIDR notation of the bastion host allowed to SSH in to the machines"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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

variable "aws_ssm_iam_role_name" {
  description = "The name of the SSM EC2 role to associate with Kasm VMs for SSH access"
  type        = string
  default     = ""
}

variable "aws_ssm_instance_profile_name" {
  description = "The name of the SSM EC2 Instance Profile to associate with Kasm VMs for SSH access"
  type        = string
  default     = ""
}

variable "database_password" {
  description = "The password for the database. No special characters"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "The password for the Redis server. No special characters"
  type        = string
  sensitive   = true
}

variable "user_password" {
  description = "The standard (non administrator) user password. No special characters"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "The administrative user password. No special characters"
  type        = string
  sensitive   = true
}

variable "manager_token" {
  description = "The manager token value for Agents to authenticate to webapps. No special characters"
  type        = string
  sensitive   = true
}

variable "service_registration_token" {
  description = "The service registration token value for cpx RDP servers to authenticate to webapps. No special characters"
  type        = string
  sensitive   = true
}

variable "kasm_zone_name" {
  description = "A name given to the kasm deployment Zone"
  type        = string
  default     = "default"
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

variable "public_lb_security_rules" {
  description = "A map of objects of security rules to apply to the Public ALB"
  type = map(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  default = {
    https = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
    http = {
      from_port = 80
      to_port   = 80
      protocol  = "tcp"
    }
  }
}

variable "private_lb_security_rules" {
  description = "A map of objects of security rules to apply to the Private ALB"
  type = map(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  default = {
    https = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
  }
}

variable "webapp_security_rules" {
  description = "A map of objects of security rules to apply to the Kasm WebApp server"
  type = object({
    from_port = number
    to_port   = number
    protocol  = string
  })

  default = {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }
}

variable "db_security_rules" {
  description = "A map of objects of security rules to apply to the Kasm DB"
  type = map(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  default = {
    postgres = {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
    }
    redis = {
      from_port = 6379
      to_port   = 6379
      protocol  = "tcp"
    }
  }
}

variable "cpx_security_rules" {
  description = "A map of objects of security rules to apply to the Kasm Connection Proxy server"
  type = map(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  default = {
    https = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
  }
}

variable "agent_security_rules" {
  description = "A map of objects of security rules to apply to the Kasm WebApp server"
  type = map(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  default = {
    https = {
      from_port = 443
      to_port   = 443
      protocol  = "tcp"
    }
  }
}

variable "windows_security_rules" {
  description = "A map of objects of security rules to apply to the Kasm Windows VMs"
  type = map(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  default = {
    cpx_rdp = {
      from_port = 3389
      to_port   = 3389
      protocol  = "tcp"
    }
    cpx_api = {
      from_port = 4902
      to_port   = 4902
      protocol  = "tcp"
    }
    webapp_api = {
      from_port = 4902
      to_port   = 4902
      protocol  = "tcp"
    }
  }
}

variable "default_egress" {
  description = "Default egress security rule for all security groups"
  type = map(object({
    from_port    = number
    to_port      = number
    protocol     = string
    cidr_subnets = list(string)
  }))

  default = {
    all = {
      from_port    = 0
      to_port      = 0
      protocol     = "-1"
      cidr_subnets = ["0.0.0.0/0"]
    }
  }
}

variable "ssh_authorized_keys" {
  description = "The SSH Public Keys to be installed on the compute instances"
  type        = string
}

