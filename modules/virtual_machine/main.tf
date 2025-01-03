resource "azurerm_linux_virtual_machine" "main" {
  name                            = "vm-${var.application_name}-${var.environment_name}"
  size                            = "Standard_D2s_v3"
  admin_username                  = "adminuser"
  admin_password                  = "#AdminPwd_1"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.main.id]
  resource_group_name             = var.resource_group_name
  location                        = var.location

  os_disk {
    name                 = "osdisk-${var.application_name}-${var.environment_name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.application_name}-${var.environment_name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig-${var.application_name}-${var.environment_name}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "disk-${var.application_name}-${var.environment_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  resource_group_name  = var.resource_group_name
  location             = var.location
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  managed_disk_id    = azurerm_managed_disk.main.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_public_ip" "main" {
  name                = "pip-${var.application_name}-${var.environment_name}"
  allocation_method   = "Static"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_virtual_machine_extension" "main" {
  name                 = "vmext-${var.application_name}-${var.environment_name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  virtual_machine_id   = azurerm_linux_virtual_machine.main.id

  settings = <<SETTINGS
  {
    "commandToExecute": "sudo snap install docker"
  }
  SETTINGS
}
