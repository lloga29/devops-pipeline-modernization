# Development Environment Variables

environment         = "dev"
location            = "East US"
project_name        = "devops-modernization"
resource_group_name = "rg-devops-dev"

# Network Configuration
vnet_name             = "vnet-devops-dev"
vnet_address_space    = ["10.0.0.0/16"]
subnet_name           = "snet-aks-dev"
subnet_address_prefixes = ["10.0.1.0/24"]

# AKS Configuration
aks_cluster_name    = "aks-devops-dev"
aks_dns_prefix      = "aks-devops-dev"
kubernetes_version  = "1.28"
aks_node_count      = 2
aks_vm_size         = "Standard_D2s_v3"
enable_auto_scaling = false
min_node_count      = 1
max_node_count      = 3
service_cidr        = "10.1.0.0/16"
dns_service_ip      = "10.1.0.10"

# ACR Configuration
acr_name = "acrdevopsdev001"
acr_sku  = "Basic"
