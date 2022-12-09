output "password" {
  value = data.azurerm_resource_group.rg.name
  sensitive = true
}
