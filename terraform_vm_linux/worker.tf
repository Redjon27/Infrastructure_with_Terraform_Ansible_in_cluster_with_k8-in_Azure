resource "azurerm_linux_virtual_machine" "worker" {
  count                 = var.worker_count
  name                  = "worker-${count.index+1}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [element(azurerm_network_interface.worker.*.id, count.index)]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "WorkerDisk-${count.index+1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "worker-${count.index+1}"
  admin_username                  = "azureuser"

admin_ssh_key {
   username   = "azureuser"
   public_key = file("./key/terraform.pub")
}

}

# Create network interface
resource "azurerm_network_interface" "worker" {
  count               = var.worker_count
  name                = "worker-${var.network_interface_name}-${count.index+1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.worker.*.id, count.index)
  }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "worker" {
  count = length(azurerm_network_interface.worker.*.id)
  network_interface_id      = element(azurerm_network_interface.worker.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create public IPs
resource "azurerm_public_ip" "worker" {
  count               = var.worker_count
  name                = "worker-${var.public_ip_name}-${count.index+1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}
