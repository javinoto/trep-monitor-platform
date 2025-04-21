terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
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
resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "Y1"    # Consumption plan

  tags = var.tags
}

# 5. Function App
resource "azurerm_linux_function_app" "func" {
  name                       = "${var.prefix}-func"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  functions_extension_version = "~4"

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
    TELEGRAM_BOT_TOKEN       = var.telegram_bot_token
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appinsights.connection_string
  }

  tags = var.tags
}

# 6. Insights App for monitoring
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}-ainsights"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = var.tags
}
