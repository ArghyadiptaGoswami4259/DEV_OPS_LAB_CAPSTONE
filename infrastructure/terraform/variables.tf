variable "cluster_name" {
  description = "Dedicated TaskFlow Kubernetes profile"
  type        = string
  default     = "taskflow-capstone"

  validation {
    condition     = var.cluster_name == "taskflow-capstone"
    error_message = "Use the dedicated taskflow-capstone profile."
  }
}

variable "cluster_cpus" {
  description = "CPU allocation for Minikube"
  type        = number
  default     = 4
}

variable "cluster_memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 4096
}
