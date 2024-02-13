terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "TaskBoardRG123"
    storage_account_name = "taskboardstorage"
    container_name       = "taskboardcontainerpeterpatev"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Create the Linux app service plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = var.service_plan_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
}

# Create the web app, pass in App service plan ID
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_service_plan.app_service_plan.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

# Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "source_control" {
  app_id                 = azurerm_linux_web_app.web_app.id
  repo_url               = var.repo_URL
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.resource_group.name
  location                     = azurerm_resource_group.resource_group.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "mssql_database" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.mssql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "S0"
  zone_redundant = false
}

resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
