data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

# Azure Container Registry to store Docker images.
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name # <- fixed name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

# AKS cluster with system-assigned managed identity (simple dev setup).
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name            = "nodepool1"
    node_count      = var.node_count
    vm_size         = var.node_size
    os_disk_size_gb = 60
    type            = "VirtualMachineScaleSets"
    vnet_subnet_id  = azurerm_subnet.aks.id
  }

  identity { type = "SystemAssigned" }

  # Azure CNI with explicit address spaces (no overlap with VNet!)
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    # network_policy   = "calico" # optional
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file(pathexpand("~/.ssh/id_rsa.pub"))
    }
  }
}

# Grant AKS kubelet permission to pull images from ACR.
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_prefix]
}