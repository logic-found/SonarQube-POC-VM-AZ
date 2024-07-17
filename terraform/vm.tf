resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-${var.project_name}-${var.env}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  tags = {
    env : var.env,
    application_name = var.project_name
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.project_name}-${var.env}"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"] 
}

resource "azurerm_public_ip" "public_ip" {
  name                = "pip-${var.project_name}-${var.env}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  domain_name_label = var.domain_name
  tags = {
    env : var.env,
    application_name = var.project_name
  }
}

resource "azurerm_network_interface" "network_interface" {
  name                = "nic-${var.project_name}-${var.env}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  tags = {
    env : var.env,
    application_name = var.project_name
  }
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = "nsg-${var.project_name}-${var.env}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  security_rule {
    name                       = "allow_http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_ssh"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    env : var.env,
    application_name = var.project_name
  }
}

resource "azurerm_network_interface_security_group_association" "network_interface_security_group_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                = "vm-${var.project_name}-${var.env}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_B2s"
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  network_interface_ids = [
    azurerm_network_interface.network_interface.id,
  ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = {
    env : var.env,
    application_name = var.project_name
  }
  depends_on = [
    azurerm_network_interface.network_interface,
    azurerm_public_ip.public_ip
  ]
}

resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "vm-extension-${var.project_name}-${var.env}"
  virtual_machine_id   = azurerm_linux_virtual_machine.virtual_machine.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  protected_settings   = <<PROTECTED_SETTINGS
 {
  "script": "c3VkbyBhcHQtZ2V0IHVwZGF0ZQpzdWRvIGFwdC1nZXQgaW5zdGFsbCAteSBhcHQtdHJhbnNwb3J0LWh0dHBzIGNhLWNlcnRpZmljYXRlcyBjdXJsIHNvZnR3YXJlLXByb3BlcnRpZXMtY29tbW9uCmN1cmwgLWZzU0wgaHR0cHM6Ly9kb3dubG9hZC5kb2NrZXIuY29tL2xpbnV4L3VidW50dS9ncGcgfCBzdWRvIGdwZyAtLWRlYXJtb3IgLW8gL3Vzci9zaGFyZS9rZXlyaW5ncy9kb2NrZXItYXJjaGl2ZS1rZXlyaW5nLmdwZwplY2hvICJkZWIgW2FyY2g9JChkcGtnIC0tcHJpbnQtYXJjaGl0ZWN0dXJlKSBzaWduZWQtYnk9L3Vzci9zaGFyZS9rZXlyaW5ncy9kb2NrZXItYXJjaGl2ZS1rZXlyaW5nLmdwZ10gaHR0cHM6Ly9kb3dubG9hZC5kb2NrZXIuY29tL2xpbnV4L3VidW50dSAkKGxzYl9yZWxlYXNlIC1jcykgc3RhYmxlIiB8IHN1ZG8gdGVlIC9ldGMvYXB0L3NvdXJjZXMubGlzdC5kL2RvY2tlci5saXN0ID4gL2Rldi9udWxsCnN1ZG8gYXB0LWdldCB1cGRhdGUKYXB0LWNhY2hlIHBvbGljeSBkb2NrZXItY2UKc3VkbyBhcHQgaW5zdGFsbCAteSBkb2NrZXItY2UKc3VkbyBzeXN0ZW1jdGwgc3RhcnQgZG9ja2VyCnN1ZG8gc3lzdGVtY3RsIGVuYWJsZSBkb2NrZXIKc3VkbyBkb2NrZXIgcHVsbCBzb25hcnF1YmU6bHRzCnN1ZG8gZG9ja2VyIHJ1biAtZCAtLW5hbWUgc29uYXJxdWJlIC1wIDkwMDA6OTAwMCBzb25hcnF1YmU6bHRzCg=="
 }
  PROTECTED_SETTINGS
}
