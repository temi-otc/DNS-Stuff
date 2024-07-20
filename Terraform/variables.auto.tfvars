
new_rg = "Hybrid-TF"

Vnet1 = "Hub-Vnet"

Vnet2 = "SpokeA-Vnet"

# Vnet3 = "SpokeB-Vnet"

Vnet4 = "OnPrem-Vnet"

location = "Canada Central"

FirewallSubnet = "AzureFirewallSubnet"

VNG-Sub1 = "GatewaySubnet"

VNG-Sub2 = "GatewaySubnet"

FW-name = "Hub-FW"

VNG1-name = "VNG-Azure"

VNG2-name = "VNG-OnPrem"

LNG1-name = "AZ-OnPrem-LNG"

LNG2-name = "OnPrem-AZ-LNG"

Tunnel1-name = "AZ-OnPrem-CONN"

Tunnel2-name = "OnPrem-AZ-CONN"

VM-sub1 = "VM-Sub-Hub"

VM-sub2 = "VM-Sub-SpkA"

# VM-sub3 = "VM-Sub-SpkB"

VM-sub4 = "VM-Sub-OnPrem"

UDR-GW = "GW-RT"

UDR-VM-SPK = "VM-SPKA-RT"

UDR-VM-HUB = "VM-HUB-RT"

vm-nic1 = "VM-Hub-nic" #Example naming convention nebla-nic-controller-001
vm-nic2 = "VM-SpkA-nic"
# vm-nic3 = "VM-SpkB-nic"
vm-nic4 = "VM-OnPrem-nic"
vm-nic5 = "VM-OnPremDC-nic"

address_prefixes1 = ["100.10.0.0/24"] # VM Subnet - HUB
address_prefixes2 = ["100.10.1.0/25"] # FW Subnet - HUB
address_prefixes3 = ["100.10.2.0/26"] # GW Subnet - HUB
address_prefixes4 = ["100.20.0.0/24"] # VM Subnet - Spoke A
# address_prefixes5 = ["100.30.0.0/24"] # VM Subnet - Spoke B
address_prefixes6 = ["172.10.0.0/24"] # VM Subnet - Remote
address_prefixes7 = ["172.10.1.0/26"] # GW Subnet - Remote

VM-name1 = "Hub-VM" #Example Naming Convention ansible-controller
VM-name2 = "VM1-SpkA"
# VM-name3 = "VM2-SPKB"
VM-name4 = "VM-OnPrem"
VM-name5 = "VM-DCPrem"
