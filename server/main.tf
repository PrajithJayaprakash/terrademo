# Create NIC
resource "azurerm_network_interface" "nic" {
  name                      = "nic-${var.servername}-001"
  location                  = var.rg_location
  resource_group_name       = var.rg_name

  ip_configuration {
    name                          = "niccfg-${var.servername}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
  }
}

data "azurerm_key_vault" "secret" {
  name                = var.secret_keyvault_name
  resource_group_name = var.secret_keyvault_rgname
}

data "azurerm_key_vault_secret" "admin" {
  name = var.admin_password
  key_vault_id = data.azurerm_key_vault.secret.id
}
/*
resource "random_password" "password" {
  length           = 8
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
*/
# Create virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.servername
  location              = var.rg_location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = data.azurerm_key_vault_secret.admin.value
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

