# QA Environment Variables

environment         = "qa"
location            = "East US"
project_name        = "devops-modernization"
resource_group_name = "rg-devops-qa"

# Network Configuration
vnet_name             = "vnet-devops-qa"
vnet_address_space    = ["10.10.0.0/16"]
subnet_name           = "snet-aks-qa"
subnet_address_prefixes = ["10.10.1.0/24"]

# AKS Configuration
aks_cluster_name    = "aks-devops-qa"
aks_dns_prefix      = "aks-devops-qa"
kubernetes_version  = "1.28"
aks_node_count      = 2
aks_vm_size         = "Standard_D4s_v3"
enable_auto_scaling = true
min_node_count      = 2
max_node_count      = 4
service_cidr        = "10.11.0.0/16"
dns_service_ip      = "10.11.0.10"

# ACR Configuration
acr_name = "acrdevopsqa001"
acr_sku  = "Standard"
