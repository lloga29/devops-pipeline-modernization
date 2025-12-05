# DevOps Pipeline Modernization

Repositorio de pipelines de CI/CD modernizados para Azure DevOps, implementando mejores prácticas de DevOps, GitOps, Infrastructure as Code y arquitectura de microservicios.

## 🎯 Objetivo

Modernizar el pipeline de CI/CD actual mediante la implementación de:
- Security gates automatizados
- Modelo GitOps con ArgoCD
- Infrastructure as Code con Terraform
- Soporte multi-cloud
- Adopción incremental con feature flags

## 🚀 Características Principales

- **Multi-lenguaje**: Java (Maven/Gradle), .NET Core, Angular, Python
- **GitOps**: Despliegue declarativo con ArgoCD y auto-healing
- **IaC**: Infraestructura versionada con Terraform
- **Security-First**: Escaneo de secretos, SAST, SCA y container scanning
- **Versionado Semántico**: Gestión automática con GitVersion
- **Multi-Environment**: Configuraciones aisladas (dev, qa, prod)

## 📋 Inicio Rápido

### Pipelines
Configure variables en `pipeline/variables.yml` y el pipeline (`main.yml`) orquestará todas las etapas automáticamente.

### GitOps
Configure ArgoCD usando `argocd-app-sample.yaml` y ajuste valores por ambiente en `gitops/envs/{env}/`.

### Infrastructure as Code
```bash
cd iac/{env}
terraform init
terraform plan -var-file={env}.tfvars
terraform apply -var-file={env}.tfvars
```

## 📚 Documentación de la Propuesta

Para facilitar la revisión de la solución, la documentación se organizó en la carpeta `docs/`:

- [Análisis del pipeline actual](docs/analisis-pipeline-actual.md)
- [Diagrama del pipeline CI/CD revisado](docs/diagrams/)
- [Conclusiones y recomendaciones](docs/conclusiones-y-recomendaciones.md)
- [Recomendaciones técnicas detalladas del pipeline](pipeline/recomendaciones.md)

### Documentación por Componente

- **Pipeline CI/CD**: Ver `pipeline/recomendaciones.md` para detalles técnicos
- **GitOps**: Ver `gitops/README.md` para configuración ArgoCD
- **IaC**: Ver `iac/README.md` para instrucciones Terraform

## 🔒 Mejores Prácticas Implementadas

- Tags semánticos en todas las imágenes (nunca `latest`)
- Security gates obligatorios antes de producción
- Git como única fuente de verdad (GitOps)
- Infraestructura versionada y reproducible
- Backend remoto para estado de Terraform
- Auto-healing con ArgoCD

## 🤝 Contribución

1. Crear rama feature desde `main`
2. Implementar cambios siguiendo convenciones
3. Crear Pull Request para revisión
4. Merge a `main` tras aprobación