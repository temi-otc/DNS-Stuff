##RESOURCE GROUP
variable "new_rg" {
  type        = string
  description = "The name of the RG"
}

##location

variable "location" {
  type    = string
  default = ""
}

##VIRTUAL NETWORK

variable "Vnet1" {
  type    = string
  default = ""
}


variable "Vnet2" {
  type    = string
  default = ""
}

# variable "Vnet3" {
#   type    = string
#   default = ""
# }

variable "Vnet4" {
  type    = string
  default = ""
}


#SUBNETS

variable "VM-sub1" {
  type    = string
  default = ""
}

variable "VM-sub2" {
  type    = string
  default = ""
}

# variable "VM-sub3" {
#   type    = string
#   default = ""
# }

variable "VM-sub4" {
  type    = string
  default = ""
}

variable "FirewallSubnet" {
  type    = string
  default = ""
}

variable "VNG-Sub1" {
  type    = string
  default = ""
}

variable "VNG-Sub2" {
  type    = string
  default = ""
}

## FIREWALL NAME
variable "FW-name" {
  type    = string
  default = ""
}

## GATEWAY + LNG + CONNECTION NAME

variable "VNG1-name" {
  type    = string
  default = ""
}

variable "VNG2-name" {
  type    = string
  default = ""
}

variable "LNG1-name" {
  type    = string
  default = ""
}

variable "LNG2-name" {
  type    = string
  default = ""
}

variable "Tunnel1-name" {
  type    = string
  default = ""
}

variable "Tunnel2-name" {
  type    = string
  default = ""
}

##address prefix
variable "address_prefixes1" {
  type = list(string)
}

variable "address_prefixes2" {
  type = list(string)
}

variable "address_prefixes3" {
  type = list(string)
}

variable "address_prefixes4" {
  type = list(string)
}

# variable "address_prefixes5" {
#   type = list(string)
# }

variable "address_prefixes6" {
  type = list(string)
  
}
variable "address_prefixes7" {
  type = list(string)
}

##NETWORK INTERFACES
variable "vm-nic1" {
  type    = string
  default = ""
}

variable "vm-nic2" {
  type    = string
  default = ""
}

# variable "vm-nic3" {
#   type    = string
#   default = ""
# }
variable "vm-nic4" {
  type    = string
  default = ""
}

variable "vm-nic5" {
  type    = string
  default = ""
}

##ROUTE TABLES FOR GATEWAY AND SPOKE-VM

variable "UDR-GW" {
  type    = string
  default = ""
}

variable "UDR-VM-SPK" {
  type    = string
  default = ""
}

variable "UDR-VM-HUB" {
  type    = string
  default = ""
}
## VM NAME
variable "VM-name1" {
  type    = string
  default = ""
}

variable "VM-name2" {
  type    = string
  default = ""
}

# variable "VM-name3" {
#   type    = string
#   default = ""
# }
variable "VM-name4" {
  type    = string
  default = ""
}

variable "VM-name5" {
  type    = string
  default = ""
}


#CREDENTIALS

variable "username" {
  type = string
  default = "temi"
}

variable "password" {
  type = string
  default = "Olanike@1973"
}

