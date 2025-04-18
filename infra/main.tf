provider "azurerm" {
  features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

# 2. Storage Account
resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# 3. Blob Container for images
resource "azurerm_storage_container" "images" {
  name                    = "telegram-images"
  storage_account_id      = azurerm_storage_account.sa.id
  container_access_type   = "private"
}

# 4. App Service Plan (for Functions)
resource "azurerm_app_service_plan" "plan" {
  name                = "${var.prefix}-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = var.tags
}

# 5. Function App
resource "azurerm_function_app" "func" {
  name                       = "${var.prefix}-func"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  version                    = "~4"

  site_config {
    linux_fx_version = "Python|3.10"
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
    TELEGRAM_BOT_TOKEN       = var.telegram_bot_token
  }

  tags = var.tags
}
