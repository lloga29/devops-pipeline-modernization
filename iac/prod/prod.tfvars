# Production Environment Variables

environment         = "prod"
location            = "East US"
project_name        = "devops-modernization"
resource_group_name = "rg-devops-prod"

# Network Configuration
vnet_name             = "vnet-devops-prod"
vnet_address_space    = ["10.100.0.0/16"]
subnet_name           = "snet-aks-prod"
subnet_address_prefixes = ["10.100.1.0/24"]

# AKS Configuration
aks_cluster_name    = "aks-devops-prod"
aks_dns_prefix      = "aks-devops-prod"
kubernetes_version  = "1.28"
aks_node_count      = 5
aks_vm_size         = "Standard_D8s_v3"
enable_auto_scaling = true
min_node_count      = 5
max_node_count      = 10
service_cidr        = "10.101.0.0/16"
dns_service_ip      = "10.101.0.10"

# ACR Configuration
acr_name = "acrdevopsprod001"
acr_sku  = "Premium"
acr_geo_replication_location = "West US"
