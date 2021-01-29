variable "project" {
  type        = string
  description = "The project ID to host the compute nodes in (required)"
}

variable "region" {
  type        = string
  description = "The region to deploy the compute nodes in"
  default     = "us-central1"
}

variable "zone" {
  type        = list(string)
  description = "The zones to deploy the compute nodes in"
  default     = ["a", "c", "d", "f"]
}

variable "machine_type" {
  type        = string
  description = "The machine type to use for the compute nodes"
  default     = "n1-standard-1"
}

variable "network" {
  type        = string
  description = "The machine type to use for the compute nodes"
  default     = "default"
}

variable "tags" {
  type        = list(string)
  description = "The tags to attach to the compute nodes"
  default     = ["boundary"]
}

variable "service_account_scopes" {
  type        = list(string)
  description = "The service account scopes to attach to the compute nodes"
  default     = ["compute-ro", "cloud-platform"]
}

variable "operating_system" {
  type        = string
  description = "Operating system to use for the compute nodes"
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "boundary_controller_count" {
  type        = number
  description = "The number of Boundary Controller instances to provision"
  default     = 1
}

variable "boundary_worker_count" {
  type        = number
  description = "The number of Boundary Workers instances to provision"
  default     = 1
}