locals {
  name_template = join("-", compact([lower(var.environment), lower(var.module), lower(var.slot)]))
  tags = {
    environment = lower(var.environment)
    module      = lower(var.module)
    slot        = lower(var.slot)
  }
}