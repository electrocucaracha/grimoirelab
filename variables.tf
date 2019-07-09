variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  default     = "~/.ssh/id_rsa"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "GRIMOIRELAB_ORG" {
  default     = "openstack"
}
