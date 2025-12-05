
# GitOps Configuration

Este directorio implementa la metodología GitOps para el despliegue automatizado de aplicaciones en Kubernetes usando ArgoCD como herramienta de Continuous Deployment.

## 🎯 Filosofía GitOps

GitOps es un paradigma de operaciones que utiliza Git como única fuente de verdad para la infraestructura declarativa y las aplicaciones. Los principios fundamentales son:

1. **Declarativo**: Todo el estado deseado del sistema se describe declarativamente
2. **Versionado e Inmutable**: Todo se almacena en Git, proporcionando historial completo
3. **Pull Automático**: Los agentes automáticamente extraen el estado deseado desde Git
4. **Reconciliación Continua**: Software agents aseguran que el estado actual coincida con el deseado

## 📁 Estructura

```
gitops/
├── README.md                      # Este archivo
├── argocd-app-sample.yaml        # Template de Application de ArgoCD
└── envs/                         # Configuraciones por ambiente
    ├── dev/
    │   └── values-dev.yaml       # Valores Helm para desarrollo
    ├── qa/
    │   └── values-qa.yaml        # Valores Helm para QA
    └── prod/
        └── values-prod.yaml      # Valores Helm para producción
```

## 🔄 Flujo GitOps Implementado

### 1. Desarrollo y Build (CI Pipeline)
```
Código → Build → Tests → Crear Imagen Docker → Push a Registry
                                                ↓
                                         Tag: X.Y.Z-env
```

### 2. Actualización de Manifiestos
```
Pipeline CI actualiza → values-{env}.yaml con nuevo tag
                              ↓
                         Commit a Git
                              ↓
                      ArgoCD detecta cambio
```

### 3. Despliegue Automático (CD con ArgoCD)
Este mismo modelo lo uso para separar dev/qa/prod y permitir que promociones pasen siempre por un commit trazable.


```
ArgoCD monitorea Git → Detecta cambio → Compara con cluster
                                              ↓
                                    Estado actual ≠ deseado?
                                              ↓
                                        Sincroniza
                                              ↓
                                    Deploy a Kubernetes
```

### 4. Auto-Healing
```
Drift detectado → ArgoCD restaura → Estado vuelve al definido en Git
```

## 🚀 Configuración de ArgoCD

### Crear una Application

```bash
kubectl apply -f argocd-app-sample.yaml
```

O via ArgoCD CLI:

```bash
argocd app create my-app \
  --repo https://github.com/lloga29/devops-pipeline-modernization.git \
  --path gitops/envs/dev \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Configuración de la Application

El archivo `argocd-app-sample.yaml` define:

- **source**: Repositorio Git y path a las configuraciones
- **destination**: Cluster y namespace de destino
- **syncPolicy**: Política de sincronización
  - `automated`: Sincronización automática en cada commit
  - `prune: true`: Elimina recursos que ya no están en Git
  - `selfHeal: true`: Corrige drift automáticamente
  - `retry`: Política de reintentos con backoff exponencial

## 🌍 Ambientes

### Development (`dev/`)
- **Propósito**: Pruebas de desarrollo y integración continua
- **Características**:
  - 1 réplica
  - Tag: `0.0.1-dev` (versionado semántico con sufijo)
  - `pullPolicy: Always` para usar siempre la última imagen
  - Recursos limitados (500m CPU, 512Mi RAM)
  - Log level: `debug`
  - Sin TLS

### QA (`qa/`)
- **Propósito**: Testing y validación pre-producción
- **Características**:
  - 2 réplicas base
  - Tag: `0.1.0-qa` (versión RC/release candidate)
  - Autoscaling habilitado (2-4 pods)
  - Recursos medios (1000m CPU, 1Gi RAM)
  - Log level: `info`
  - TLS con certificado staging

### Production (`prod/`)
- **Propósito**: Ambiente productivo
- **Características**:
  - 3 réplicas mínimas
  - Tag: `1.0.0` (versión estable sin sufijo)
  - Autoscaling agresivo (3-10 pods)
  - Recursos amplios (2000m CPU, 2Gi RAM)
  - Log level: `warn`
  - TLS con certificado producción
  - Pod Disruption Budget (mínimo 2 pods siempre)
  - Anti-affinity para distribuir pods

## 📋 Mejores Prácticas Implementadas

### ✅ Versionado Semántico
```yaml
# ❌ NUNCA
tag: latest
tag: stable

# ✅ SIEMPRE
tag: 1.2.3          # Producción
tag: 1.2.3-qa       # QA
tag: 0.0.1-dev      # Desarrollo
```

### ✅ Separación de Ambientes
Cada ambiente tiene:
- Archivo de valores independiente
- Configuraciones específicas de recursos
- Políticas de escalado diferenciadas
- Niveles de logging apropiados

### ✅ Progresión de Ambientes
```
dev (0.0.x-dev) → qa (0.x.0-qa) → prod (x.0.0)
```

### ✅ Inmutabilidad
- Los tags de imagen nunca se reutilizan
- Cada despliegue tiene un tag único
- Rollback = cambiar al tag anterior en Git

## 🔒 Seguridad

### Políticas de Pull
- **Dev**: `Always` - siempre pull para desarrollo ágil
- **QA/Prod**: `IfNotPresent` - usa cache cuando es posible

### TLS/SSL
- Dev: Sin TLS (HTTP)
- QA: Certificados staging (Let's Encrypt)
- Prod: Certificados producción validados

### Pod Security
- Prod incluye PodDisruptionBudget
- Anti-affinity para alta disponibilidad
- Resource limits estrictos

## 🛠️ Uso Práctico

### Desplegar Nueva Versión

1. **CI Pipeline construye y tagea imagen**:
   ```bash
   docker build -t myregistry/app:1.2.3 .
   docker push myregistry/app:1.2.3
   ```

2. **Pipeline actualiza values-prod.yaml**:
   ```yaml
   image:
     tag: "1.2.3"  # Cambio automático por pipeline
   ```

3. **Commit y Push**:
   ```bash
   git add gitops/envs/prod/values-prod.yaml
   git commit -m "chore: update prod to v1.2.3"
   git push
   ```

4. **ArgoCD detecta y despliega automáticamente**

### Rollback

```bash
# Opción 1: Via Git (recomendado)
git revert <commit-hash>
git push

# Opción 2: Via ArgoCD UI
# History → Select previous version → Sync

# Opción 3: Via ArgoCD CLI
argocd app rollback my-app <revision>
```

### Verificar Estado

```bash
# Ver status de sincronización
argocd app get my-app

# Ver diferencias
argocd app diff my-app

# Ver historial
argocd app history my-app
```

## 🔍 Monitoreo

ArgoCD proporciona:
- **Health Status**: Estado de salud de los recursos
- **Sync Status**: Estado de sincronización con Git
- **App Diff**: Diferencias entre Git y cluster
- **Audit Trail**: Historial completo de despliegues
- **Notifications**: Alertas de cambios y problemas

## 🎓 Beneficios del Flujo GitOps

1. **Auditabilidad**: Todo cambio queda registrado en Git
2. **Reproducibilidad**: Cualquier versión es recuperable
3. **Simplicidad**: Despliegue = Git commit
4. **Seguridad**: Single source of truth, menos acceso directo a clusters
5. **Velocity**: Automatización completa del CD
6. **Rollback**: Trivial via Git revert
7. **Disaster Recovery**: Cluster completo desde Git

## 📚 Referencias

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
