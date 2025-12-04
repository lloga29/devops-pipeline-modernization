# DevOps Pipeline Modernization

Repositorio de pipelines de CI/CD modernizados para Azure DevOps, implementando mejores prácticas de DevOps, GitOps y arquitectura de microservicios.

## 📁 Estructura del Repositorio

```
devops-pipeline-modernization/
│
├── README.md
│
├── pipeline/                           # Definiciones de CI/CD Azure DevOps
│   ├── main.yml                        # Pipeline principal
│   ├── variables.yml                   # Variables compartidas
│   ├── recomendaciones.md             # Documentación de mejores prácticas
│   ├── SatrackVars*.yml               # Variables específicas por proyecto
│   │
│   ├── build/                          # Etapa de construcción
│   │   ├── development-integration.yml
│   │   └── jobs/
│   │       ├── angular-job.yml         # Build para aplicaciones Angular
│   │       ├── java-gradle-job.yml     # Build para proyectos Java con Gradle
│   │       ├── java-maven-job.yml      # Build para proyectos Java con Maven
│   │       ├── netcore-job.yml         # Build para aplicaciones .NET Core
│   │       └── python-job.yml          # Build para aplicaciones Python
│   │
│   ├── general/                        # Utilidades generales
│   │   ├── GitVersion.yml              # Configuración de versionado
│   │   └── semantic-version-job.yml    # Job de versionado semántico
│   │
│   ├── qa/                             # Etapa de calidad y testing
│   │   ├── integration-tests.yml       # Tests de integración
│   │   ├── performance-tests.yml       # Tests de rendimiento
│   │   ├── public-interface-tests.yml  # Tests de contratos API
│   │   ├── technical-excellence-assurance.yml
│   │   └── jobs/
│   │       ├── arch-test-gradle-job.yml
│   │       ├── arch-test-maven-job.yml
│   │       ├── arch-test-netcore-job.yml
│   │       ├── integration-test-gradle-job.yml
│   │       ├── integration-test-maven-job.yml
│   │       ├── integration-test-netcore-job.yml
│   │       ├── performance-test-job.yml
│   │       ├── public-interface-test-job.yml
│   │       └── security-quality-gates-job.yml  # Gates de seguridad
│   │
│   └── release/                        # Etapa de release y despliegue
│       ├── artifacts-management.yml    # Gestión de artefactos
│       ├── create-pull-request.yml     # Creación automática de PRs
│       ├── ecosystem-integration.yml   # Integración con ecosistema
│       └── jobs/
│           ├── kubernetes-deploy-jobs.yml  # Despliegue a Kubernetes
│           ├── Update-tag.yml          # Actualización de tags
│           └── terraform-iac.yml       # Jobs de Terraform IaC
│
├── gitops/                             # Configuraciones GitOps
│   ├── README.md                       # Documentación GitOps completa
│   ├── argocd-app-sample.yaml         # Ejemplo de aplicación ArgoCD
│   └── envs/                          # Configuraciones por ambiente
│       ├── dev/
│       │   └── values-dev.yaml        # Valores para desarrollo (tag: 0.0.1-dev)
│       ├── qa/
│       │   └── values-qa.yaml         # Valores para QA (tag: 0.1.0-qa)
│       └── prod/
│           └── values-prod.yaml       # Valores para producción (tag: 1.0.0)
│
└── iac/                                # Infrastructure as Code (Terraform)
    ├── README.md                       # Documentación IaC
    ├── dev/
    │   ├── main.tf                     # Recursos Terraform para desarrollo
    │   └── dev.tfvars                  # Variables de desarrollo
    ├── qa/
    │   ├── main.tf                     # Recursos Terraform para QA
    │   └── qa.tfvars                   # Variables de QA
    └── prod/
        ├── main.tf                     # Recursos Terraform para producción
        └── prod.tfvars                 # Variables de producción
```

## 🚀 Características

### Pipeline CI/CD
- **Multi-lenguaje**: Soporte para Java (Maven/Gradle), .NET Core, Angular y Python
- **Versionado Semántico**: GitVersion para gestión automática de versiones
- **Quality Gates**: Tests de arquitectura, integración, rendimiento y seguridad
- **Artifacts Management**: Gestión centralizada de artefactos
- **Kubernetes Deploy**: Despliegue automatizado a clusters Kubernetes
- **IaC Integration**: Integración con Terraform para gestión de infraestructura

### GitOps
- **ArgoCD Integration**: Despliegue declarativo mediante ArgoCD
- **Multi-Environment**: Configuraciones separadas para dev, qa y prod
- **Semantic Versioning**: Tags semánticos en todas las imágenes
- **Auto-Sync**: Sincronización automática con self-healing

### Infrastructure as Code (IaC)
- **Terraform**: Definición declarativa de infraestructura Azure
- **Multi-Environment**: Configuraciones separadas por ambiente
- **AKS Clusters**: Provisionamiento automatizado de Kubernetes
- **ACR Integration**: Azure Container Registry con integración automática
- **Remote State**: Backend remoto para gestión de estado compartido

## 📋 Uso

### Pipelines
1. Configure las variables necesarias en `pipeline/variables.yml` o `SatrackVars-*.yml`
2. El pipeline principal (`main.yml`) orquesta todas las etapas
3. Los jobs específicos se ejecutan según el tipo de proyecto detectado

### GitOps
1. Configure su aplicación en ArgoCD usando `argocd-app-sample.yaml` como referencia
2. Ajuste los valores por ambiente en `gitops/envs/{env}/values-{env}.yaml`
3. ArgoCD sincronizará automáticamente los cambios del repositorio

### Infrastructure as Code
1. Navegue al ambiente deseado: `cd iac/{env}`
2. Inicialice Terraform: `terraform init`
3. Revise los cambios: `terraform plan -var-file={env}.tfvars`
4. Aplique la infraestructura: `terraform apply -var-file={env}.tfvars`

## 🔒 Mejores Prácticas

- **Tags Semánticos**: Nunca use `latest` o `stable`, siempre versiones semánticas
- **Security Gates**: Todos los despliegues pasan por validaciones de seguridad
- **GitOps**: El repositorio es la única fuente de verdad
- **Ambientes Separados**: Configuraciones aisladas por ambiente
- **IaC Declarativo**: Infraestructura versionada y reproducible
- **State Management**: Backend remoto de Terraform para colaboración
- **Auto-Healing**: ArgoCD corrige automáticamente las desviaciones

## 📚 Documentación Adicional

- Ver `pipeline/recomendaciones.md` para mejores prácticas de pipelines
- Ver `gitops/README.md` para detalles de configuración GitOps
- Ver `iac/README.md` para instrucciones de Infrastructure as Code

## 🤝 Contribución

1. Crear una rama feature desde `main`
2. Implementar cambios siguiendo las convenciones del repositorio
3. Crear Pull Request para revisión
4. Una vez aprobado, merge a `main`