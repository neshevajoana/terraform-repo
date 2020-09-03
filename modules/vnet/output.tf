output "virtual_network_name" {
    description = "Name of Virtual Network"
    value = "${azurerm_virtual_network.vnet.name}"
}