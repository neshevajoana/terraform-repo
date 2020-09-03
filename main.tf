provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "resource-group-dmz"
  location = "East US"
}
#create a Virtual Network.
module "vnet" {
  source = "./modules/vnet"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.resource_group.location}"
  name                = "dmzVnet"
}

# Create subnets.
resource "azurerm_subnet" "webTierSubnet" {
  name                 = "web_tier_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "${module.vnet.virtual_network_name}"
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "businessTierSubnet" {
  name                 = "business_tier_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "${module.vnet.virtual_network_name}"
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "dataTierSubnet" {
  name                 = "data_tier_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "${module.vnet.virtual_network_name}"
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_subnet" "gatewaySubnet" {
  name                 = "gateway_subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "${module.vnet.virtual_network_name}"
  address_prefixes     = ["10.0.255.224/27"]
}

# Create NSG and Network Security rules for Web Tier.
resource "azurerm_network_security_group" "nsg_webTier" {
  name                = "webTierNetworkSecurityGroup"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "nsr_webTier1" {
  name                        = "Web8080"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "10.0.4.4"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_webTier.name
}

resource "azurerm_network_security_rule" "nsr_webTier2" {
  name                        = "Web80"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "10.0.4.4"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_webTier.name
}
resource "azurerm_network_security_rule" "nsr_webTier3" {
  name                        = "Web443"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "10.0.4.4"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_webTier.name
}
resource "azurerm_network_security_rule" "nsr_webTier4" {
  name                        = "RDP3389"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.0.0.0/27"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_webTier.name
}
resource "azurerm_network_security_rule" "nsr_webTier5" {
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
  network_security_group_name = azurerm_network_security_group.nsg_webTier.name
}
resource "azurerm_subnet_network_security_group_association" "webTierSubnetAssociation" {
  subnet_id                 = azurerm_subnet.webTierSubnet.id
  network_security_group_id = azurerm_network_security_group.nsg_webTier.id
}
# Create NSG and Network Security rules for Business Tier.
resource "azurerm_network_security_group" "nsg_businessTier" {
  name                = "businessTierNetworkSecurityGroup"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_network_security_rule" "nsr_businessTier1" {
  name                        = "RDP3389"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "10.0.2.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_businessTier.name
}
resource "azurerm_network_security_rule" "nsr_businessTier2" {
  name                        = "RDP_webTier_3389"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.0.0.0/27"
  destination_address_prefix  = "10.0.2.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_businessTier.name
}
resource "azurerm_subnet_network_security_group_association" "businesTierSubnetAssociation" {
  subnet_id                 = azurerm_subnet.businessTierSubnet.id
  network_security_group_id = azurerm_network_security_group.nsg_businessTier.id
}
# Create NSG and Network Security rules for Data Tier.
resource "azurerm_network_security_group" "nsg_dataTier" {
  name                = "dataTierNetworkSecurityGroup"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_network_security_rule" "nsr_dataTier1" {
  name                        = "RDP3389"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.0.2.0/24"
  destination_address_prefix  = "10.0.3.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_dataTier.name
}
resource "azurerm_network_security_rule" "nsr_dataTier2" {
  name                        = "RDP_businessTier_3389"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.0.0.0/27"
  destination_address_prefix  = "10.0.3.0/24"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_dataTier.name
}
resource "azurerm_subnet_network_security_group_association" "dataTierSubnetAssociation" {
  subnet_id                 = azurerm_subnet.dataTierSubnet.id
  network_security_group_id = azurerm_network_security_group.nsg_dataTier.id
}
# Create NSG and Network Security rules for Azure Bastion.
resource "azurerm_network_security_group" "nsg_azbastion" {
  name                = "azBastionNetworkSecurityGroup"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_rule" "nsr_azBastion1" {
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
  network_security_group_name = azurerm_network_security_group.nsg_azbastion.name
}

resource "azurerm_network_security_rule" "nsr_azBastion2" {
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
  network_security_group_name = azurerm_network_security_group.nsg_azbastion.name
}
resource "azurerm_network_security_rule" "nsr_azBastion3" {
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
  network_security_group_name = azurerm_network_security_group.nsg_azbastion.name
}
resource "azurerm_network_security_rule" "nsr_azBastion4" {
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
  network_security_group_name = azurerm_network_security_group.nsg_azbastion.name
}

# Create NIC.
resource "azurerm_network_interface" "webTier" {
  name                = "webTier_nic"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfiguration_web"
    subnet_id                     = azurerm_subnet.webTierSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "webTier2" {
  name                = "webTier_nic2"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfiguration_web"
    subnet_id                     = azurerm_subnet.webTierSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "businessTier" {
  name                = "business_nic"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfiguration_business"
    subnet_id                     = azurerm_subnet.businessTierSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "businessTier2" {
  name                = "business_nic2"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfiguration_business"
    subnet_id                     = azurerm_subnet.businessTierSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "dataTier" {
  name                = "data_nic"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfiguration_data"
    subnet_id                     = azurerm_subnet.dataTierSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "dataTier2" {
  name                = "data_nic2"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfiguration_data"
    subnet_id                     = azurerm_subnet.dataTierSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Create VMs for Web Tier.
resource "azurerm_windows_virtual_machine" "webTierVm1" {
  name                = "webTierVm1"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.webTier.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "webTierVm2" {
  name                = "webTierVm2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.webTier2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
# Create VMs for Business Tier.
resource "azurerm_windows_virtual_machine" "businessTierVm1" {
  name                = "businessTierVm1"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.businessTier.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "businessTierVm2" {
  name                = "businessTierVm2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.businessTier2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
# Create VM for Data Tier.
resource "azurerm_windows_virtual_machine" "dataTierVm1" {
  name                = "dataTierVm1"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.dataTier.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "dataTierVm2" {
  name                = "dataTierVm2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.dataTier2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
#Create Azure Firewall.

resource "azurerm_subnet" "azureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "${module.vnet.virtual_network_name}"
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_public_ip" "publicIP" {
  name                = "azfirewall_ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_firewall" "azureFirewall" {
  name                = "azureFirewall"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                 = "ipconfiguration_azfirewall"
    subnet_id            = azurerm_subnet.azureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.publicIP.id
  }
}
resource "azurerm_firewall_network_rule_collection" "azFirewallnsrcollection" {
  name                = "azFirewall_nsr1"
  azure_firewall_name = azurerm_firewall.azureFirewall.name
  resource_group_name = azurerm_resource_group.resource_group.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

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
resource "azurerm_route_table" "az_route_table" {
  name                = "webTierRouteTable"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_route" "webTierRoute" {
  name                   = "webTierRoute1"
  resource_group_name    = azurerm_resource_group.resource_group.name
  route_table_name       = azurerm_route_table.az_route_table.name
  address_prefix         = "10.0.1.0/24"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "10.0.4.4"
}

# Create Azure Bastion
resource "azurerm_subnet" "azBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = "${module.vnet.virtual_network_name}"
  address_prefixes     = ["10.0.0.0/27"]
}

resource "azurerm_public_ip" "azBastionPublicIp" {
  name                = "azbastionPubluicIp1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "azureBastionHost" {
  name                = "azBastionHost1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                 = "ipconfiguration_azBastion"
    subnet_id            = azurerm_subnet.azBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.azBastionPublicIp.id
  }
}

# Create load balancer for Web Tier.

resource "azurerm_public_ip" "loadBalanceriPWebTier" {
  name                = "PublicIPForLB"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "loadbalancerWebTier" {
  name                = "TestLoadBalancer"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.loadBalanceriPWebTier.id
    private_ip_address   = "10.0.1.100"
  }
}

resource "azurerm_lb_backend_address_pool" "lbBackendPool" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.loadbalancerWebTier.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "lbRule" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.loadbalancerWebTier.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_network_interface_backend_address_pool_association" "backendPoolAddressWebTier" {
  network_interface_id    = azurerm_network_interface.webTier.id
  ip_configuration_name   = "ipconfiguration_web"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbBackendPool.id
}
# Create load balancer for Business Tier.

resource "azurerm_public_ip" "loadBalanceriPBusinessTier" {
  name                = "PublicIPForLBbusinessTier"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "loadbalancerBusinessTier" {
  name                = "TestLoadBalancerBusinessTier"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.loadBalanceriPBusinessTier.id
    private_ip_address   = "10.0.2.100"
  }
}

resource "azurerm_lb_backend_address_pool" "lbBackendPoolBusinessTier" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.loadbalancerBusinessTier.id
  name                = "BackEndAddressPoolBusinessTier"
}

resource "azurerm_lb_rule" "lbRuleBusinessTier" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.loadbalancerBusinessTier.id
  name                           = "LBRule1"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_network_interface_backend_address_pool_association" "backendPoolAddressBusinessTier" {
  network_interface_id    = azurerm_network_interface.businessTier.id
  ip_configuration_name   = "ipconfiguration_business"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbBackendPoolBusinessTier.id
}
# Create load balancer for Data Tier.

resource "azurerm_public_ip" "loadBalanceriPDataTier" {
  name                = "PublicIPForLBdataTier"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "loadbalancerDataTier" {
  name                = "TestLoadBalancerDataTier"
  location            = "East US"
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.loadBalanceriPDataTier.id
    private_ip_address   = "10.0.3.100"
  }
}

resource "azurerm_lb_backend_address_pool" "lbBackendPoolDataTier" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.loadbalancerDataTier.id
  name                = "BackEndAddressPoolDataTier"
}

resource "azurerm_lb_rule" "lbRuleDataTier" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.loadbalancerDataTier.id
  name                           = "LBRuleDataTier"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_network_interface_backend_address_pool_association" "backendPoolAddressDataTier" {
  network_interface_id    = azurerm_network_interface.dataTier.id
  ip_configuration_name   = "ipconfiguration_data"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbBackendPoolDataTier.id
}
