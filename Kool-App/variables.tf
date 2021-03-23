variable env {
  type    = string
  description = "Environment Name"
  default = "prod"
}
variable location-name {
  type    = string
  default = "westeurope"
}

variable function-size {
  type    = string
  default = "EP2"
}

variable function-tier {
  type    = string
  default = "Premium"
}

variable sql-sku {
  type    = string
}

variable login {
  type    = string
  }

variable pwd {
  type    = string
  }



# variable "apim_name" {
#   type        = string
#   description = "API Management Name"
#   }

# variable "api_name" {
#   type        = string
#   description = "Default API Name"
#   }

# variable "api_path" {
#   type        = string
#   description = "Default API Path"
#   }

# variable "api_url" {
#   type        = string
#   description = "Default API URL"
#   }