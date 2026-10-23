
resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "${var.prefix}-web-vmss"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.vm_size
  instances           = 1
  zones               = length(var.availability_zones) > 0 ? var.availability_zones : null
  upgrade_mode        = "Manual"

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "web-vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.web_vmss.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }

  #web page so the LB probe on port 80 succeeds
  custom_data = base64encode(<<-CLOUD
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "Hello from $(hostname)" > /var/www/html/index.html
    systemctl enable --now nginx
  CLOUD
  )

  depends_on = [
    azurerm_subnet_network_security_group_association.web,
    azurerm_lb_rule.http
  ]
}

resource "azurerm_monitor_autoscale_setting" "web" {
  name                = "${var.prefix}-web-autoscale"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web.id

  profile {
    name = "cpu-based"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
