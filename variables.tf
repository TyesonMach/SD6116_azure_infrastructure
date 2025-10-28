variable "rg_name" {
  description = "Name of an existing Azure Resource Group to deploy into."
  type        = string
  default     = "playground-toanmachcanh"
}

variable "acr_name" {
  description = "Azure Container Registry name (globally unique, lowercase/digits)."
  type        = string
  default     = "acrdevopssd6116"
}

variable "prefix" {
  description = "Short name prefix for resources."
  type        = string
  default     = "devx"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "southeastasia"
}

variable "node_count" {
  description = "AKS node count for dev."
  type        = number
  default     = 1
}

variable "node_size" {
  description = "VM size for AKS nodes."
  type        = string
  default     = "Standard_B2s"
}

# Exact AKS cluster name you want.
variable "aks_name" {
  description = "Exact name for the AKS cluster."
  type        = string
  default     = "aksdevopssd6116"
  validation {
    condition     = length(var.aks_name) >= 1 && length(var.aks_name) <= 63 && can(regex("^[a-z0-9-]+$", var.aks_name))
    error_message = "AKS name must be 1–63 chars, lowercase letters, digits, or hyphens."
  }
}

# DNS prefix used by the AKS API endpoint (can be same as name).
variable "dns_prefix" {
  description = "DNS prefix for AKS; 1–54 chars."
  type        = string
  default     = "aksdevopssd6116"
  validation {
    condition     = length(var.dns_prefix) >= 1 && length(var.dns_prefix) <= 54 && can(regex("^[a-z0-9-]+$", var.dns_prefix))
    error_message = "DNS prefix must be 1–54 chars, lowercase letters, digits, or hyphens."
  }
}

# --- VNet/Subnet for AKS ---
variable "vnet_name" {
  description = "VNet name."
  type        = string
  default     = "dev-vnet"
}
variable "vnet_address_space" {
  description = "VNet address space."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}
variable "aks_subnet_name" {
  description = "AKS subnet name."
  type        = string
  default     = "aks-subnet"
}
variable "aks_subnet_prefix" {
  description = "AKS subnet CIDR (inside the VNet space)."
  type        = string
  default     = "10.20.0.0/22"
}

# AKS service CIDR (must NOT overlap VNet)
variable "service_cidr" {
  description = "ClusterIP range for services."
  type        = string
  default     = "172.16.0.0/16"
}
variable "dns_service_ip" {
  description = "kube-dns IP inside service_cidr."
  type        = string
  default     = "172.16.0.10"
}