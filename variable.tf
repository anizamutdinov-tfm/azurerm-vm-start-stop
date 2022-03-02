variable "resource_group_name" {
  description = "Resource group name to allocate subnet"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "module" {
  description = "Project module name"
  type        = string
}

variable "slot" {
  description = "Project slot name. Available values: shared, blue, green"
  type        = string
}

variable "vm_name" {
  description = "Name of VM to stop/start"
  type        = string
}

variable "start_schedule" {
  type = object({
    frequency = string
    interval  = number
    start     = string
  })
  default = {
    frequency = ""
    interval  = 0
    start     = ""
  }
}

variable "stop_schedule" {
  type = object({
    frequency = string
    interval  = number
    start     = string
  })
  default = {
    frequency = ""
    interval  = 0
    start     = ""
  }
}

variable "custom_tags" {
  description = "Custom tags to add"
  type        = map(string)
  default     = {}
}
