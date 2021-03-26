terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "kool-rg" {
  name     = "${var.env}-kool-rg"
  location = var.location-name
  tags = {
    environment = var.env
  }
}

module "kool-vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "${var.env}-kool-vnet"
  resource_group_name = azurerm_resource_group.kool-rg.name
  address_space       = ["10.0.0.0/23"]
  subnet_prefixes     = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_names        = ["${var.env}-app-subnet", "${var.env}-data-subnet"]

  subnet_service_endpoints = {
    "${var.env}-data-subnet" = ["Microsoft.Sql"]
  }
  tags = {
    environment = var.env
  }
  depends_on = [azurerm_resource_group.kool-rg]
}

resource "azurerm_storage_account" "sa" {
  //name                      = "${var.env}-kool-sg"
  name                      = "${var.env}koolsg"
  resource_group_name       = azurerm_resource_group.kool-rg.name
  location                  = azurerm_resource_group.kool-rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  allow_blob_public_access  = false
  enable_https_traffic_only = true

  tags = {
    environment = var.env
  }
}

resource "azurerm_app_service_plan" "func" {
  name                = "${var.env}-kool-fplan"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  kind                = "functionapp"
  reserved            = true


  # Add SKU Env Condition!!
  sku {
    size = var.function-size
    tier = var.function-tier
  }
  tags = {
    environment = var.env
  }
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.env}-insight"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  application_type    = "web"

}

resource "azurerm_function_app" "function" {
  name                       = "${var.env}-kool-func"
  resource_group_name        = azurerm_resource_group.kool-rg.name
  location                   = azurerm_resource_group.kool-rg.location
  app_service_plan_id        = azurerm_app_service_plan.func.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  https_only                 = true
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "custom"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
  }
  depends_on = [azurerm_app_service_plan.func, azurerm_application_insights.appinsights, azurerm_storage_account.sa]
}

resource "azurerm_app_service_plan" "asp" {
  name                = "${var.env}-kool-applan"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  sku {
    size = var.function-size
    tier = var.function-tier
  }
  tags = {
    environment = var.env
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "${var.env}-kool-webapp"
  location            = azurerm_resource_group.kool-rg.location
  resource_group_name = azurerm_resource_group.kool-rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
}

resource "azurerm_app_service_active_slot" "webappslot" {
  resource_group_name   = azurerm_resource_group.kool-rg.name
  app_service_name      = azurerm_app_service.webapp.name
  app_service_slot_name = "${var.env}-kool-wslot"
}

resource "azurerm_mssql_server" "sqlsvc" {
  name                         = "${var.env}-kool-sqlsvc"
  resource_group_name          = azurerm_resource_group.kool-rg.name
  location                     = azurerm_resource_group.kool-rg.location
  version                      = "12.0"
  administrator_login          = var.login
  administrator_login_password = var.pwd
}

# resource "azurerm_mssql_virtual_network_rule" "netrule" {
#   name      = "${var.env}-kool-sql-vnet-rule"
#   server_id = azurerm_mssql_server.sqlsvc.id
#   subnet_id = module.kool-vnet.subnet_names.id 

# }

resource "azurerm_mssql_database" "sqldb" {
  name           = "${var.env}-kool-db"
  server_id      = azurerm_mssql_server.sqlsvc.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = var.sql-sku
  zone_redundant = true

  tags = {
    environment = var.env
  }

}


resource "azurerm_api_management" "apim" {
  name                = "${var.env}-apim"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  publisher_name      = "${var.env}-apim"
  publisher_email     = var.apim-publisher_email
  sku_name            = var.apim-sku
}

resource "azurerm_stream_analytics_job" "stream_analytics_job" {
  name                                     = "${var.env}-job"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location
  compatibility_level                      = "1.1"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3

  tags = {
    environment = "Example"
  }

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}


# data "azurerm_stream_analytics_job" "stream_analytics_job" {
#   name                = "${var.env}-job"
#   resource_group_name = azurerm_resource_group.kool-rg.name
  
# }

resource "azurerm_iothub" "iothub" {
  name                = "${var.env}-iothub"
  resource_group_name = azurerm_resource_group.kool-rg.name
  location            = azurerm_resource_group.kool-rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_stream_analytics_stream_input_iothub" "stream_input" {
  name                         = "${var.env}-iothub-input"
  # stream_analytics_job_name    = data.azurerm_stream_analytics_job.stream_analytics_job.name
  stream_analytics_job_name    = azurerm_stream_analytics_job.stream_analytics_job.name
  resource_group_name          = azurerm_resource_group.kool-rg.name
  endpoint                     = "messages/events"
  eventhub_consumer_group_name = "$Default"
  iothub_namespace             = azurerm_iothub.iothub.name
  shared_access_policy_key     = azurerm_iothub.iothub.shared_access_policy[0].primary_key
  shared_access_policy_name    = "iothubowner"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}
