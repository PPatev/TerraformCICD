variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group"
}

variable "service_plan_name" {
  type        = string
  description = "The name of the app service plan"
}

variable "app_service_name" {
  type        = string
  description = "The name of the app"
}

variable "sql_server_name" {
  type        = string
  description = "The name of the sql server"
}

variable "sql_database_name" {
  type        = string
  description = "The name of the sql database"
}

variable "sql_admin_login" {
  type        = string
  description = "The username login of admin"
}

variable "sql_admin_password" {
  type        = string
  description = "The password of the admin"
}

variable "firewall_rule_name" {
  type        = string
  description = "The name of the firewall rule"
}

variable "repo_URL" {
  type        = string
  description = "The url of the source control repo"
}