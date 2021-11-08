
variable "vmNames" {
  type    = list(string)
  default = ["vmServer", "vmNode1"]
  description = "Input the names of VMs to be created"
}

variable "location" {
    type = string
    default = "eastus"
    description = "Input the location string for the vm"
}

variable "userAdminKey" {
    type = string
    description = "Enter Password for vm admin"
    sensitive = true
}

variable "vmScripts" {
    type = list(string)
    description = "Script file names for vm provisioning"
    default = ["jenkinserver.sh" , "jenkinsnode.sh"]
}