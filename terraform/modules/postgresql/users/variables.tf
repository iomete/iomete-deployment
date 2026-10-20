variable "username" {
  description = "The name of the user to create"
  type        = string
}

variable "user_creation_depends_on" {
  description = "Array of dependents user creation should wait for"
  type        = any
  default     = []
}
