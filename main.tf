provider "azurerm" {
  features {}
}
locals {
  web_tier_subnet      = "10.0.1.0/24"
  business_tier_subnet = "10.0.2.0/24"
  data_tier_subnet     = "10.0.3.0/24"
  firewall_ip_address  = "10.0.4.4"
  azure_bastion_subnet = "10.0.0.0/27"
}
# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "resource_group_dmz"
  location = "East US"
}
#create a Virtual Network.
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
}
# Create subnets.
resource "azurerm_subnet" "web_tier" {
  name                 = "web_tier_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "business_tier" {
  name                 = "business_tier_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "data_tier" {
  name                 = "data_tier_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_subnet" "gateway" {
  name                 = "gateway_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.255.224/27"]
}
# Create NSG and Network Security rules for Web Tier.
resource "azurerm_network_security_group" "web_tier" {
  name                = "nsg_web_tier"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_network_security_rule" "nsr_1_web_tier" {
  name                        = "Web8080"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = local.firewall_ip_address
  destination_address_prefix  = local.web_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.web_tier.name
}
resource "azurerm_network_security_rule" "nsr_2_web_tier" {
  name                        = "Web80"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = local.firewall_ip_address
  destination_address_prefix  = local.web_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.web_tier.name
}
resource "azurerm_network_security_rule" "nsr_3_web_tier" {
  name                        = "Web443"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = local.firewall_ip_address
  destination_address_prefix  = local.web_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.web_tier.name
}
resource "azurerm_network_security_rule" "nsr_4_web_tier" {
  name                        = "RDP3389"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = local.azure_bastion_subnet
  destination_address_prefix  = local.web_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.web_tier.name
}
resource "azurerm_network_security_rule" "nsr_5_web_tier" {
  name                        = "RDP_3389"
  priority                    = 1005
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.2.100"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.web_tier.name
}
resource "azurerm_subnet_network_security_group_association" "web_tier" {
  subnet_id                 = azurerm_subnet.web_tier.id
  network_security_group_id = azurerm_network_security_group.web_tier.id
}
# Create NSG and Network Security rules for Business Tier.
resource "azurerm_network_security_group" "business_tier" {
  name                = "nsg_business_tier"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_network_security_rule" "nsr_1_business_tier" {
  name                        = "RDP3389"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = local.web_tier_subnet
  destination_address_prefix  = local.business_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.business_tier.name
}
resource "azurerm_network_security_rule" "nsr_2_business_tier" {
  name                        = "RDP_webTier_3389"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = local.azure_bastion_subnet
  destination_address_prefix  = local.business_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.business_tier.name
}
resource "azurerm_subnet_network_security_group_association" "busines_tier" {
  subnet_id                 = azurerm_subnet.business_tier.id
  network_security_group_id = azurerm_network_security_group.business_tier.id
}
# Create NSG and Network Security rules for Data Tier.
resource "azurerm_network_security_group" "data_tier" {
  name                = "nsg_data_tier"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_network_security_rule" "nsr_1_data_tier" {
  name                        = "RDP3389"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = local.business_tier_subnet
  destination_address_prefix  = local.data_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.data_tier.name
}
resource "azurerm_network_security_rule" "nsr_2_data_tier" {
  name                        = "RDP_businessTier_3389"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = local.azure_bastion_subnet
  destination_address_prefix  = local.data_tier_subnet
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.data_tier.name
}
resource "azurerm_subnet_network_security_group_association" "data_tier" {
  subnet_id                 = azurerm_subnet.data_tier.id
  network_security_group_id = azurerm_network_security_group.data_tier.id
}
# Create NSG and Network Security rules for Azure Bastion.
resource "azurerm_network_security_group" "azure_bastion" {
  name                = "nsg_azure_bastion"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_network_security_rule" "nsr_1_azure_bastion" {
  name                        = "RDP3389"
  priority                    = 1001
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "nsr_2_azure_bastion" {
  name                        = "SSH22"
  priority                    = 1002
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "nsr_3_azure_bastion" {
  name                        = "web443"
  priority                    = 1003
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
resource "azurerm_network_security_rule" "nsr_4_azure_bastion" {
  name                        = "web_443"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.azure_bastion.name
}
# Create VMs for Web Tier.
module "vmWeb" {
  source              = "./modules/vmWeb"
  subnet_id           = azurerm_subnet.web_tier.id
  resource_group_name = azurerm_resource_group.resource_group.name
}
# Create VMs for Business Tier.
module "vmBusiness" {
  source              = "./modules/vmBusiness"
  subnet_id           = azurerm_subnet.business_tier.id
  resource_group_name = azurerm_resource_group.resource_group.name
}
# Create VM for Data Tier.
module "vmData" {
  source              = "./modules/vmData"
  subnet_id           = azurerm_subnet.data_tier.id
  resource_group_name = azurerm_resource_group.resource_group.name
}
#Create Azure Firewall.
resource "azurerm_subnet" "azure_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.4.0/24"]
}
resource "azurerm_public_ip" "azure_firewall" {
  name                = "azure_firewall_public_ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_firewall" "azure_firewall" {
  name                = "azure_firewall"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                 = "ipconfiguration_azfirewall"
    subnet_id            = azurerm_subnet.azure_firewall.id
    public_ip_address_id = azurerm_public_ip.azure_firewall.id
  }
}
resource "azurerm_firewall_network_rule_collection" "azure_firewall" {
  name                = "nsr_azure_firewall"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.resource_group.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "nsr_1_azure_firewall"

    source_addresses = [
      "10.0.0.0/16",
    ]

    destination_ports = [
      "53",
      "443",
      "80",
      "8080"
    ]
    destination_addresses = [
      "10.0.1.0/24"
    ]
    protocols = [
      "TCP",
      "UDP"
    ]
  }
}
# Create a route table.
resource "azurerm_route_table" "web_tier" {
  name                = "web_tier_route_table"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_route" "web_tier" {
  name                   = "web_tier_route_1"
  resource_group_name    = azurerm_resource_group.resource_group.name
  route_table_name       = azurerm_route_table.web_tier.name
  address_prefix         = local.web_tier_subnet
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = local.firewall_ip_address
}
# Create Azure Bastion
resource "azurerm_subnet" "azure_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = module.vnet.virtual_network_name
  address_prefixes     = ["10.0.0.0/27"]
}
resource "azurerm_public_ip" "azure_bastion" {
  name                = "azure_bastion_piblic_ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_bastion_host" "azure_bastion" {
  name                = "azure_bastion_host"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                 = "ipconfig_azure_bastion_host"
    subnet_id            = azurerm_subnet.azure_bastion.id
    public_ip_address_id = azurerm_public_ip.azure_bastion.id
  }
}
# Create load balancer for Web Tier.
resource "azurerm_public_ip" "web_tier" {
  name                = "public_ip_lb_web"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}
resource "azurerm_lb" "web_tier" {
  name                = "load_balancer_web_tier"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "public_ip_lb_web"
    public_ip_address_id = azurerm_public_ip.web_tier.id
    private_ip_address   = "10.0.1.100"
  }
}
resource "azurerm_lb_backend_address_pool" "web_tier" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.web_tier.id
  name                = "back_end_address_pool_web"
}
resource "azurerm_lb_rule" "web_tier" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.web_tier.id
  name                           = "lb_rule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "public_ip_lb_web"
}
# Create load balancer for Business Tier.
resource "azurerm_public_ip" "business_tier" {
  name                = "public_ip_lb_business"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}
resource "azurerm_lb" "business_tier" {
  name                = "load_balancer_business_tier"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "public_ip_lb_business"
    public_ip_address_id = azurerm_public_ip.business_tier.id
    private_ip_address   = "10.0.2.100"
  }
}
resource "azurerm_lb_backend_address_pool" "business_tier" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.business_tier.id
  name                = "back_end_address_pool_business"
}
resource "azurerm_lb_rule" "business_tier" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.business_tier.id
  name                           = "lb_rule_1"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "public_ip_lb_business"
}
# Create load balancer for Data Tier.
resource "azurerm_public_ip" "data_tier" {
  name                = "public_ip_lb_data"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}
resource "azurerm_lb" "data_tier" {
  name                = "load_balancer_data_tier"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "public_ip_lb_data"
    public_ip_address_id = azurerm_public_ip.data_tier.id
    private_ip_address   = "10.0.3.100"
  }
}
resource "azurerm_lb_backend_address_pool" "data_tier" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.data_tier.id
  name                = "back_end_address_pool_data"
}
resource "azurerm_lb_rule" "data_tier" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.data_tier.id
  name                           = "lb_rule_data_tier"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "public_ip_lb_data"
}

