data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_machine" "vm" {
  resource_group_name = var.resource_group_name
  name                = var.vm_name
}

resource "azurerm_logic_app_workflow" "lapp_start" {
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = join("-", ["lapp-start", local.name_template])
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_logic_app_trigger_recurrence" "lapp_start_schedule" {
  count        = var.start_schedule.interval == 0 ? 0 : 1
  logic_app_id = azurerm_logic_app_workflow.lapp_start.id
  name         = format("run-each-%s-%ss", var.start_schedule.interval, var.start_schedule.frequency)
  frequency    = var.start_schedule.frequency
  interval     = var.start_schedule.interval
  start_time   = var.start_schedule.start
}

resource "azurerm_logic_app_action_http" "lapp_start_action" {
  logic_app_id = azurerm_logic_app_workflow.lapp_start.id
  name         = "start-vm"
  method       = "POST"
  uri          = format("https://management.azure.com%s/start?api-version=2019-03-01", data.azurerm_virtual_machine.vm.id)
}

resource "azurerm_role_assignment" "lapp_start_role" {
  principal_id         = azurerm_logic_app_workflow.lapp_start.identity[0].principal_id
  scope                = data.azurerm_virtual_machine.vm.id
  role_definition_name = "Contributor"
}

resource "azurerm_logic_app_workflow" "lapp_stop" {
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = join("-", ["lapp-stop", local.name_template])
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_logic_app_trigger_recurrence" "lapp_stop_schedule" {
  count        = var.stop_schedule.interval == 0 ? 0 : 1
  logic_app_id = azurerm_logic_app_workflow.lapp_stop.id
  name         = format("run-each-%s-%ss", var.stop_schedule.interval, var.stop_schedule.frequency)
  frequency    = var.stop_schedule.frequency
  interval     = var.stop_schedule.interval
  start_time   = var.stop_schedule.start
}

resource "azurerm_logic_app_action_http" "lapp_stop_action" {
  logic_app_id = azurerm_logic_app_workflow.lapp_stop.id
  name         = "start-vm"
  method       = "POST"
  uri          = format("https://management.azure.com%s/powerOff?api-version=2019-03-01", data.azurerm_virtual_machine.vm.id)
}

resource "azurerm_role_assignment" "lapp_stop_role" {
  principal_id         = azurerm_logic_app_workflow.lapp_stop.identity[0].principal_id
  scope                = data.azurerm_virtual_machine.vm.id
  role_definition_name = "Contributor"
}