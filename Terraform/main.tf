
#creating the RG

resource "azurerm_resource_group" "Resource-group" {
  name     = var.new_rg
  location = var.location
}

#Creating the Vnet and subnets for the HUB

resource "azurerm_virtual_network" "Virtual-network-HUB" {
  name                = var.Vnet1
  address_space       = ["100.10.0.0/16"]
  location            = var.location
  resource_group_name = var.new_rg
  depends_on = [ azurerm_resource_group.Resource-group ]
}

#creating the FW subnet

resource "azurerm_subnet" "FW-Subnet" {
  name                 = var.FirewallSubnet
  resource_group_name  = var.new_rg
  virtual_network_name = var.Vnet1
  address_prefixes     = var.address_prefixes2
  depends_on = [ azurerm_virtual_network.Virtual-network-HUB, azurerm_resource_group.Resource-group ]
}

# Creating the Gateway subnet - HUB

resource "azurerm_subnet" "GW-Subnet-Hub" {
  name                 = var.VNG-Sub1
  resource_group_name  = var.new_rg
  virtual_network_name = var.Vnet1
  address_prefixes     = var.address_prefixes3
  depends_on = [ azurerm_virtual_network.Virtual-network-HUB, azurerm_resource_group.Resource-group ]
}

#creating the VM subnet -HUB

resource "azurerm_subnet" "VM-Subnet-Hub" {
  name                 = var.VM-sub1
  resource_group_name  = var.new_rg
  virtual_network_name = var.Vnet1
  address_prefixes     = var.address_prefixes1
  depends_on = [ azurerm_virtual_network.Virtual-network-HUB, azurerm_resource_group.Resource-group ]
}


#Creating the Vnet and subnets for the Spoke-A-Vnet

resource "azurerm_virtual_network" "Virtual-network-SPK-A" {
  name                = var.Vnet2
  address_space       = ["100.20.0.0/16"]
  location            = var.location
  resource_group_name = var.new_rg
  depends_on = [ azurerm_resource_group.Resource-group ]
}

#creating the VM subnet - SPoke

resource "azurerm_subnet" "VM-Subnet-SPK-A" {
  name                 = var.VM-sub2
  resource_group_name  = var.new_rg
  virtual_network_name = var.Vnet2
  address_prefixes     = var.address_prefixes4
  depends_on = [ azurerm_virtual_network.Virtual-network-SPK-A]
}

# #Creating the Vnet and subnets for the Spoke-B-Vnet

# resource "azurerm_virtual_network" "Virtual-network-SPK-B" {
#   name                = var.Vnet3
#   address_space       = ["100.30.0.0/16"]
#   location            = var.location
#   resource_group_name = var.new_rg
#   depends_on = [ azurerm_resource_group.Resource-group ]
# }

# #creating the VM subnet - SPoke

# resource "azurerm_subnet" "VM-Subnet-SPK-B" {
#   name                 = var.VM-sub3
#   resource_group_name  = var.new_rg
#   virtual_network_name = var.Vnet3
#   address_prefixes     = var.address_prefixes5
#   depends_on = [ azurerm_virtual_network.Virtual-network-SPK-B, azurerm_resource_group.Resource-group ]
# }

#Creating the Vnet and subnets for the OnPrem-Vnet

resource "azurerm_virtual_network" "Virtual-network-Prem" {
  name                = var.Vnet4
  address_space       = ["172.10.0.0/16"]
  location            = var.location
  resource_group_name = var.new_rg
  depends_on = [ azurerm_resource_group.Resource-group ]
}

# Creating the Gateway subnet - OnPrem

resource "azurerm_subnet" "GW-Subnet-Prem" {
  name                 = var.VNG-Sub2
  resource_group_name  = var.new_rg
  virtual_network_name = var.Vnet4
  address_prefixes     = var.address_prefixes7
  depends_on = [ azurerm_virtual_network.Virtual-network-Prem ]
}

#creating the VM subnet - OnPrem

resource "azurerm_subnet" "VM-Subnet-Prem" {
  name                 = var.VM-sub4
  resource_group_name  = var.new_rg
  virtual_network_name = var.Vnet4
  address_prefixes     = var.address_prefixes6
  depends_on = [ azurerm_virtual_network.Virtual-network-Prem ]
}


###### CREATE VM FOR HUB-VNET

#CREATE VM PUBLIC IP 
resource "azurerm_public_ip" "VMhub-pip" {
  name                = "VM-pip-hub"
  resource_group_name = var.new_rg
  location            = var.location
  allocation_method   = "Static"
}

#CREATE NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "Nsg-for-all"
  location            = var.location
  resource_group_name = var.new_rg

  security_rule {
    name                       = "PORT_3389_ALLOW_INBOUND"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "212.27.187.70/32"
    destination_address_prefix = "*"
  }
}

#ASSOCIATE NSG TO SUBNET
resource "azurerm_subnet_network_security_group_association" "nsg_vm_association" {
  subnet_id                 = azurerm_subnet.VM-Subnet-Hub.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#CREATE VM NIC
resource "azurerm_network_interface" "vm-nic-hub" {
  name                = var.vm-nic1
  location            = var.location
  resource_group_name = var.new_rg

  ip_configuration {
    name                          = "VM-hub-conf"
    subnet_id                     = azurerm_subnet.VM-Subnet-Hub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VMhub-pip.id
  }
}


#CREATE VM-HUB

resource "azurerm_windows_virtual_machine" "VM-hub" {
  name                = var.VM-name1
  resource_group_name = var.new_rg
  location            = var.location
  size                = "Standard_E2s_v3"
  admin_username      = var.user-name
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.vm-nic-hub.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

   source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-pro"
    version   = "latest"
  }
}


###### CREATE VM FOR SPOKE-A-VNET

#CREATE NSG

resource "azurerm_network_security_group" "nsg-Spk-A" {
  name                = "NsgSpk-A"
  location            = var.location
  resource_group_name = var.new_rg

  security_rule {
    name                       = "PORT_3389_ALLOW_INBOUND"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "212.27.187.70/32"
    destination_address_prefix = "*"
  }
}

#ASSOCIATE NSG TO SUBNET
resource "azurerm_subnet_network_security_group_association" "nsg_vm_association2" {
  subnet_id                 = azurerm_subnet.VM-Subnet-SPK-A.id
  network_security_group_id = azurerm_network_security_group.nsg-Spk-A.id
}

#CREATE VM NIC-SPOKE
resource "azurerm_network_interface" "vm-nic-spk-A" {
  name                = var.vm-nic2
  location            = var.location
  resource_group_name = var.new_rg

  ip_configuration {
    name                          = "VM-spk-A-conf"
    subnet_id                     = azurerm_subnet.VM-Subnet-SPK-A.id
    private_ip_address_allocation = "Dynamic"
  }
}

#CREATE VM-SPOKE

resource "azurerm_windows_virtual_machine" "VM-spk-A" {
  name                = var.VM-name2
  resource_group_name = var.new_rg
  location            = var.location
  size                = "Standard_E2s_v3"
  admin_username      = var.user-name
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.vm-nic-spk-A.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-pro"
    version   = "latest"
  }

  # source_image_reference {
  #   publisher = "MicrosoftWindowsServer"
  #   offer     = "WindowsServer"
  #   sku       = "2016-Datacenter"
  #   version   = "latest"
  # }
}
###### CREATE VM FOR SPOKE-B-VNET

# #CREATE NSG

# resource "azurerm_network_security_group" "nsg-Spk-B" {
#   name                = "NsgSpk-B"
#   location            = var.location
#   resource_group_name = var.new_rg

#   security_rule {
#     name                       = "PORT_3389_ALLOW_INBOUND"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "3389"
#     source_address_prefix      = "212.27.187.70/32"
#     destination_address_prefix = "*"
#   }
# }

# #ASSOCIATE NSG TO SUBNET
# resource "azurerm_subnet_network_security_group_association" "nsg_vm_association3" {
#   subnet_id                 = azurerm_subnet.VM-Subnet-SPK-B.id
#   network_security_group_id = azurerm_network_security_group.nsg-Spk-B.id
# }

# #CREATE VM NIC-SPOKE
# resource "azurerm_network_interface" "vm-nic-spk-B" {
#   name                = var.vm-nic3
#   location            = var.location
#   resource_group_name = var.new_rg

#   ip_configuration {
#     name                          = "VM-spk-B-conf"
#     subnet_id                     = azurerm_subnet.VM-Subnet-SPK-B.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# #CREATE VM-SPOKE

# resource "azurerm_windows_virtual_machine" "VM-spk-B" {
#   name                = var.VM-name3
#   resource_group_name = var.new_rg
#   location            = var.location
#   size                = "Standard_E2s_v3"
#   admin_username      = var.user-name
#   admin_password      = var.password
#   network_interface_ids = [
#     azurerm_network_interface.vm-nic-spk-B.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#  source_image_reference {
#     publisher = "microsoftwindowsdesktop"
#     offer     = "windows-11"
#     sku       = "win11-21h2-pro"
#     version   = "latest"
#   }
# }


###### CREATE VM FOR OnPrem-VNET


#CREATE VM PUBLIC IP 
resource "azurerm_public_ip" "VMPrem-pip" {
  name                = "VM-pip-prem"
  resource_group_name = var.new_rg
  location            = var.location
  allocation_method   = "Static"
}

#CREATE NSG

resource "azurerm_network_security_group" "nsg-Prem" {
  name                = "NsgPrem"
  location            = var.location
  resource_group_name = var.new_rg

  security_rule {
    name                       = "PORT_3389_ALLOW_INBOUND"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "212.27.187.70/32"
    destination_address_prefix = "*"
  }
}

#ASSOCIATE NSG TO SUBNET
resource "azurerm_subnet_network_security_group_association" "nsg_vm_association4" {
  subnet_id                 = azurerm_subnet.VM-Subnet-Prem.id
  network_security_group_id = azurerm_network_security_group.nsg-Prem.id
}

#CREATE VM NIC-OnPrem
resource "azurerm_network_interface" "vm-nic-prem" {
  name                = var.vm-nic4
  location            = var.location
  resource_group_name = var.new_rg

  ip_configuration {
    name                          = "VM-prem-conf"
    subnet_id                     = azurerm_subnet.VM-Subnet-Prem.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VMPrem-pip.id
  }
}

#CREATE VM-OnPrem

resource "azurerm_windows_virtual_machine" "VM-Prem" {
  name                = var.VM-name4
  resource_group_name = var.new_rg
  location            = var.location
  size                = "Standard_E2s_v3"
  admin_username      = var.user-name
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.vm-nic-prem.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-pro"
    version   = "latest"
  }
}

###### CREATING THE FIREWALL - HUB

#Creating the Firewall Public Ip
resource "azurerm_public_ip" "Fw-pip" {
  name                = "Fwpip"
  location            = var.location
  resource_group_name = var.new_rg
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = var.FW-name
  location            = var.location
  resource_group_name = var.new_rg
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "Firewall-conf"
    subnet_id            = azurerm_subnet.FW-Subnet.id
    public_ip_address_id = azurerm_public_ip.Fw-pip.id
  }
}

resource "azurerm_firewall_nat_rule_collection" "dnat" {
  name                = "Dnatrule"
  azure_firewall_name = var.FW-name
  resource_group_name = var.new_rg
  priority            = 180
  action              = "Dnat"

  rule {
    name = "testrule"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "20",
    ]

    destination_addresses = [
      azurerm_public_ip.Fw-pip.ip_address
    ]

    translated_port = 3389

    translated_address = "100.20.0.4"

    protocols = [
      "TCP",
      "UDP",
    ]
  }
  depends_on = [ azurerm_firewall.firewall ]
}

resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "NetworkRule"
  azure_firewall_name = var.FW-name
  resource_group_name = var.new_rg
  priority            = 150
  action              = "Allow"

  rule {
    name = "NetWrule"

    source_addresses = [
      "100.20.0.0/24",
      "100.10.0.0/24"
    ]

    destination_ports = [
      "*",

    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
  depends_on = [ azurerm_firewall.firewall ]
}

##### CREATING THE VPN GATEWAY IN THE HUB VNET

resource "azurerm_public_ip" "GW-vip-Hub" {
  name                = "GWPipHub"
  location            = var.location
  resource_group_name = var.new_rg
  sku = "Standard"

  allocation_method = "Static"
}

resource "azurerm_virtual_network_gateway" "VPNG-Hub" {
  name                = var.VNG1-name
  location            = var.location
  resource_group_name = var.new_rg

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.GW-vip-Hub.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GW-Subnet-Hub.id
  }
}

##### CREATING THE VPN GATEWAY IN THE OnPrem VNET 

resource "azurerm_public_ip" "GW-vip-Prem" {
  name                = "GWPipPrem"
  location            = var.location
  resource_group_name = var.new_rg

  sku = "Standard"

  allocation_method = "Static"
}

resource "azurerm_virtual_network_gateway" "VPNG-Prem" {
  name                = var.VNG2-name
  location            = var.location
  resource_group_name = var.new_rg

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.GW-vip-Prem.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GW-Subnet-Prem.id

  }
}


## Create PEERING BETWEEN HUB AND SPOKE-A VNET 



resource "azurerm_virtual_network_peering" "Hub-to-SPK-A" {
  name                      = "Hub-Spoke-A"
  resource_group_name       = var.new_rg
  virtual_network_name      = var.Vnet1
  remote_virtual_network_id = azurerm_virtual_network.Virtual-network-SPK-A.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = true
  use_remote_gateways = false
  depends_on  = [azurerm_virtual_network.Virtual-network-SPK-A, azurerm_virtual_network.Virtual-network-HUB, azurerm_virtual_network_gateway.VPNG-Hub]

}

resource "azurerm_virtual_network_peering" "SPK-A-to-Hub" {
  name                      = "Spoke-A-to-Hub"
  resource_group_name       = var.new_rg
  virtual_network_name      = var.Vnet2
  remote_virtual_network_id = azurerm_virtual_network.Virtual-network-HUB.id
   allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  use_remote_gateways = true
  depends_on  = [azurerm_virtual_network.Virtual-network-SPK-A, azurerm_virtual_network.Virtual-network-HUB, azurerm_virtual_network_gateway.VPNG-Hub]

}

## Create PEERING BETWEEN HUB AND SPOKE-B VNET 



# resource "azurerm_virtual_network_peering" "Hub-to-SPK-B" {
#   name                      = "Hub-Spoke-B"
#   resource_group_name       = var.new_rg
#   virtual_network_name      = var.Vnet1
#   remote_virtual_network_id = azurerm_virtual_network.Virtual-network-SPK-B.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic = true
#   allow_gateway_transit = true
#   use_remote_gateways = false
#   depends_on  = [azurerm_virtual_network.Virtual-network-SPK-B, azurerm_virtual_network.Virtual-network-HUB, azurerm_virtual_network_gateway.VPNG-Hub]

# }

# resource "azurerm_virtual_network_peering" "SPK-B-to-Hub" {
#   name                      = "Spoke-B-to-Hub"
#   resource_group_name       = var.new_rg
#   virtual_network_name      = var.Vnet3
#   remote_virtual_network_id = azurerm_virtual_network.Virtual-network-HUB.id
#    allow_virtual_network_access = true
#   allow_forwarded_traffic = true
#   allow_gateway_transit = false
#   use_remote_gateways = true
#   depends_on  = [azurerm_virtual_network.Virtual-network-SPK-B, azurerm_virtual_network.Virtual-network-HUB, azurerm_virtual_network_gateway.VPNG-Hub]


# }





resource "azurerm_virtual_network_peering" "Hub-to-SPK" {
  name                         = "Hub-Spoke"
  resource_group_name          = var.new_rg
  virtual_network_name         = var.Vnet1
  remote_virtual_network_id    = azurerm_virtual_network.Virtual-network-SPK-A.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.Virtual-network-SPK, azurerm_virtual_network.Virtual-network-HUB, azurerm_virtual_network_gateway.VPNG-Hub]
}

resource "azurerm_virtual_network_peering" "Spk-to-Hub" {
  name                         = "Spoke-Hub"
  resource_group_name          = var.new_rg
  virtual_network_name         = var.Vnet2
  remote_virtual_network_id    = azurerm_virtual_network.Virtual-network-HUB.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network.Virtual-network-SPK, azurerm_virtual_network.Virtual-network-HUB, azurerm_virtual_network_gateway.VPNG-Hub]
}


### CREATING THE SITE-TO-SITE CONNECTION FOR THE HUB GATEWAY

## Creating LNG for the HUB-GATEWAY

resource "azurerm_local_network_gateway" "AZ-OnPrem-LNG" {
  name                = var.LNG1-name
  location            = var.location
  resource_group_name = var.new_rg
  gateway_address     = "20.228.184.249"
  address_space       = ["172.10.0.0/16"]
}

## CREATING THE CONNECTION OBJECT for the HUB-Gateway


resource "azurerm_virtual_network_gateway_connection" "AZ-OnPrem-Conn" {
  name                = var.Tunnel1-name
  location            = var.location
  resource_group_name = var.new_rg

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VPNG-Hub.id
  local_network_gateway_id   = azurerm_local_network_gateway.AZ-OnPrem-LNG.id

  shared_key = "azure1234"
}



### CREATING THE SITE-TO-SITE CONNECTION FOR THE OnPrem GATEWAY

## Creating LNG for the OnPrem-GATEWAY

resource "azurerm_local_network_gateway" "OnPrem-AZ-LNG" {
  name                = var.LNG2-name
  location            = var.location
  resource_group_name = var.new_rg
  gateway_address     = "20.127.71.47"
  address_space       = ["100.10.0.0/16"]
}

## CREATING THE CONNECTION OBJECT for the OnPrem-Gateway


resource "azurerm_virtual_network_gateway_connection" "OnPrem-AZ-Conn" {
  name                = var.Tunnel2-name
  location            = var.location
  resource_group_name = var.new_rg

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.VPNG-Prem.id
  local_network_gateway_id   = azurerm_local_network_gateway.OnPrem-AZ-LNG.id

  shared_key = "azure1234"
}



#creating a route table for the Gateway in the HUB VNET

resource "azurerm_route_table" "Route-table-GWHub" {
  name                          = var.UDR-GW
  location                      = var.location
  resource_group_name           = var.new_rg
  disable_bgp_route_propagation = false

  route {
    name                   = "route-to-Spoke"
    address_prefix         = "100.20.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "100.10.1.4"
  }
}

#attaching route table

resource "azurerm_subnet_route_table_association" "Route-table-GWHub" {
  subnet_id      = azurerm_subnet.GW-Subnet-Hub.id
  route_table_id = azurerm_route_table.Route-table-GWHub.id
}

#creating a route table for the VM Subnet in the HUB VNET

resource "azurerm_route_table" "Route-table-VMHub" {
  name                          = var.UDR-VM-HUB
  location                      = var.location
  resource_group_name           = var.new_rg
  disable_bgp_route_propagation = false

  route {
    name                   = "route-to-Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "100.10.1.4"
  }

  route {
    name                   = "route-to-Spoke"
    address_prefix         = "100.20.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "100.10.1.4"
  }
}

#attaching route table

resource "azurerm_subnet_route_table_association" "Route-table-VMHub" {
  subnet_id      = azurerm_subnet.VM-Subnet-Hub.id
  route_table_id = azurerm_route_table.Route-table-VMHub.id
}

#creating a route table for the VM Subnet in the SPOKE VNET

resource "azurerm_route_table" "Route-table-VMSpk" {
  name                          = var.UDR-VM-SPK
  location                      = var.location
  resource_group_name           = var.new_rg
  disable_bgp_route_propagation = false

  route {
    name                   = "route-to-Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "100.10.1.4"
  }

  route {
    name                   = "route-to-Hub"
    address_prefix         = "100.10.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "100.10.1.4"
  }

  route {
    name                   = "route-to-Remote"
    address_prefix         = "172.19.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "100.10.1.4"
  }
}

#attaching route table

resource "azurerm_subnet_route_table_association" "Route-table-VMSpk" {
  subnet_id      = azurerm_subnet.VM-Subnet-SPK-A.id
  route_table_id = azurerm_route_table.Route-table-VMSpk.id
}

