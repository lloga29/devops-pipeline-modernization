# Infrastructure as Code (IaC)

Este directorio contiene la definición de infraestructura como código usando Terraform para todos los ambientes.

## Estructura

Cada ambiente tiene su propia configuración de Terraform con archivos separados:

- `main.tf`: Definición principal de recursos de infraestructura
- `{env}.tfvars`: Variables específicas del ambiente

## Ambientes

- **dev/**: Ambiente de desarrollo
- **qa/**: Ambiente de QA/Testing
- **prod/**: Ambiente de producción

## Uso

```bash
# Navegar al ambiente deseado
cd iac/dev

# Inicializar Terraform
terraform init

# Planificar cambios
terraform plan -var-file=dev.tfvars

# Aplicar cambios
terraform apply -var-file=dev.tfvars
```

## Mejores Prácticas

1. **Backend Remoto**: Configure backend remoto para state compartido
2. **Variables por Ambiente**: Cada ambiente tiene su archivo `.tfvars`
3. **Versionado**: Bloquee versiones de providers y módulos
4. **Validación**: Siempre ejecute `terraform plan` antes de `apply`
5. **GitOps**: Cambios via pipeline CI/CD, no manual
