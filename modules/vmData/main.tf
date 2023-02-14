resource "azurerm_network_interface" "data_tier" {
  count = length(var.nic_name)
  name                = var.nic_name[count.index]
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig.${var.nic_name[count.index]}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "data_tier" {
  count = length(var.vm_name)
  name                = var.vm_name[count.index]
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_A1"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [ azurerm_network_interface.data_tier[count.index].id ]

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