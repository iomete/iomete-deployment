variable "namespace" {
  description = "Name of the namespace to create"
  type = string
}

variable "labels" {
  description = "Labels to apply to the namespace"
  type = map(string)
  default = {}
}
