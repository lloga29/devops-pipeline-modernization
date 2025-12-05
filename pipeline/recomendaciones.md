# Oportunidades de Mejora

En la creación de las plantillas se encontraron varios aspectos que podrían mejorarse en el futuro en los pipeline como código.

## Uso de Helm para despliegues en AKS

Con esta herramienta se puede hacer la gestión de despliegues en los diferentes ambientes.

## Definición de pruebas obligatorias

Se recomienda definir el tipo de pruebas que todos los proyectos deban implementar en la ejecución del pipeline para garantizar una mayor seguridad y calidad de las aplicaciones.

## Aplicación de políticas a los repositorios

Dentro de las configuraciones que deben realizarse a los repositorios que implementen las plantillas, se debe:

1. Restringir los cambios en el código en las ramas develop, release y master.
2. Definir grupos de aprobadores para los pull requests en cada paso.

## Pipeline de creación de repositorio

Crear un pipeline que se encargue de crear los repositorios para nuevos proyectos con la estructura base de las carpetas y que se encargue de aplicar las políticas definidas para los repositorios.

## Evolución del pipeline

Se recomienda evolucionar el pipeline incluyendo:

1. Pruebas de seguridad
2. Análisis de contenedores
3. Compliance Testing
4. Pull request automáticos
5. Rollback y pruebas de humo

---

## 3.1 Modelo de stacks para el pipeline de build

Mi propuesta es unificar el modelo de pipeline alrededor de un único parámetro `stack`, de forma  que representa el stack tecnológico completo (lenguaje + tipo de build). En lugar de seguir añadiendo condiciones `if` por lenguaje, el pipeline delega en un router de build (`pipeline/build/development-integration.yml`) que invoca dinámicamente `jobs/<stack>-job.yml`.

Ej.

Stacks soportados:
- `netcore` → `jobs/netcore-job.yml`
- `java-gradle` → `jobs/java-gradle-job.yml`
- `java-maven` → `jobs/java-maven-job.yml`
- `python` → `jobs/python-job.yml`
- `angular` → `jobs/angular-job.yml`

Para añadir un nuevo stack, basta con:

1. Agregar el nuevo valor en `parameters.stack.values` en `pipeline/main.yml`.
2. Crear el archivo `pipeline/build/jobs/<stack>-job.yml` con la lógica de build y tests correspondiente.

---

## 3.2 Seguridad y quality gates en el stage de Technical Excellence

Para este punto no busco montar toda la integración real con SonarQube o Trivy, sino dejar el diseño claro dentro del pipeline y mostrar cómo se integraría la seguridad como parte estándar del flujo y no como algo separado.

En el stage `technical_excellence_assurance` (`pipeline/qa/technical-excellence-assurance.yml`) agregué un nuevo job basado en el template:

- `pipeline/qa/jobs/security-quality-gates-job.yml`

Este job se ejecuta como parte del stage de Technical Excellence y representa el bloque de **seguridad y quality gates**. Su comportamiento actual es intencionalmente sencillo, a modo de placeholder, pero deja claros los puntos de integración:

1. **Secret scanning (placeholder)**  
   Tras el `checkout`, el job ejecuta un script donde dejo explícito que aquí se integraría una herramienta tipo `gitleaks` o `trufflehog` para buscar secretos y credenciales expuestas en el repositorio.  
   En una implementación real, cualquier secreto encontrado debería terminar en `exit 1` para romper el pipeline.

2. **SAST / SonarQube (placeholder)**  
   En un segundo paso se documenta el lugar donde se ejecutaría el análisis estático (por ejemplo, SonarQube o una herramienta equivalente).  
   La idea es que el quality gate de Sonar (cobertura, vulnerabilidades, code smells, etc.) se valide aquí, y si el resultado es `FAILED` el pipeline marque el stage como fallido.

3. **Escaneo de vulnerabilidades (Trivy filesystem, placeholder)**  
   En el tercer paso se indica explícitamente que aquí entraría un `trivy fs` (u otra herramienta SCA) contra el código fuente o los artefactos generados.  
   La variable `fail_on_critical_vulns` controla la política: en el diseño, si esta variable está a `true` y el reporte contiene vulnerabilidades `CRITICAL`, el pipeline debería fallar.

Para poder activar o desactivar este bloque de seguridad sin afectar a todos los equipos de golpe, añadí variables en `pipeline/variables.yml`:

- `enable_security_scans`: permite encender o apagar el job de seguridad desde configuración.
- `fail_on_critical_vulns`: define si el pipeline debe romperse ante vulnerabilidades críticas.
- `min_coverage_threshold`, `sonar_project_key`, `sonar_service_connection`, `trivy_image`: quedan como placeholders para una futura integración real con herramientas de seguridad y análisis.

El job de seguridad se incluye en el stage `technical_excellence_assurance` respetando la lógica actual por rama y tipo de build. Esto permite que el pipeline siga funcionando como hasta ahora y, al mismo tiempo, deja preparado el punto donde se integrarían los controles de seguridad y quality gates de forma homogénea para todos los stacks (netcore, java, python, angular) cuando la organización esté lista para activarlos.

---

## 3.3 Modelo GitOps con Argo CD / Argo Rollouts / Kargo

Para evitar problemas recurrentes de versiones mezcladas entre entornos, propongo que la promoción se haga siempre vía GitOps y no por cambios manuales en Azure DevOps, en lugar de que el pipeline despliegue directamente al clúster, el modelo propuesto para 3.3 es GitOps: el pipeline actualiza la declaración de estado en un repositorio (o carpeta) de configuración y una herramienta como Argo CD se encarga de sincronizar los cambios al clúster.

En este repositorio lo represento de forma simplificada:

- Creo una estructura `gitops/` con:
  - Un `Application` de Argo CD de ejemplo (`gitops/argocd-app-sample.yaml`).
  - Valores por entorno (`gitops/envs/dev|qa|prod/values-*.yaml`) donde se declara `image.tag`.
- Adapto el job `pipeline/release/jobs/Update-tag.yml` para que:
  - Reciba como parámetros el `environment`, el `imageTag` y la ruta del `values-<env>.yaml`.
  - Actualice la clave `image.tag` en el archivo de valores (usando un script sencillo con `sed` como placeholder).
  - Documente el punto donde se haría el commit/push o se abriría un Pull Request hacia el repositorio GitOps real.
- Desde `pipeline/release/ecosystem-integration.yml`, el stage de release llama al template `Update-tag.yml` pasando el entorno y el tag generado en el build.

El flujo resultante para un entorno sería:

1. **CI**: build → tests → seguridad → generación de artefacto e imagen.
2. **Release**: el pipeline actualiza `gitops/envs/<env>/values-<env>.yaml` con el nuevo `image.tag`.
3. **GitOps**: Argo CD detecta el cambio en el repositorio de configuración y sincroniza el clúster.
4. **Despliegue progresivo** (conceptual): Argo Rollouts/Kargo gestionan la estrategia (canary/blue-green, promoción entre entornos, etc.).

En este ejercicio no implemento toda la integración real con Argo CD ni con Kargo, pero dejo clara la estructura de GitOps, el punto donde el pipeline actualiza la "verdad" (`values-*.yaml`) y cómo el modelo se extiende a múltiples entornos de forma declarativa.

---

## 3.4 Integración de IaC con Terraform y acople a GitOps

Para este punto integré un flujo de Infraestructura como Código basado en Terraform dentro del stage `ecosystem_integration`, de manera que la infraestructura se gestione con el mismo rigor que el despliegue de aplicación.

Concretamente añadí un nuevo job reusable `jobs/terraform-iac.yml`, que es invocado desde `ecosystem_integration` justo después de la actualización de tags GitOps (`jobs/Update-tag.yml`). Este job determina el entorno en función de la rama (`develop → dev`, `release → qa`, `support → atp`, `master/main/tags → prod`) y ejecuta el ciclo estándar de Terraform:

- `terraform init` para inicializar el directorio de trabajo.
- `terraform fmt -check` y `terraform validate` para asegurar consistencia y sintaxis.
- `terraform plan` con un `plan.tfplan` por entorno, que se publica como artefacto del pipeline.

Para que se pueda ver claramente dónde viviría la IaC, dejé un árbol mínimo bajo `iac/`:

```text
iac/
  dev/
    main.tf
    dev.tfvars
  qa/
    main.tf
    qa.tfvars
  prod/
    main.tf
    prod.tfvars
```

---

## 3.5 Configuración del repositorio para IaC + GitOps y soporte multinube

Hoy el pipeline está acoplado a un solo proveedor de nube.

Mi propuesta es mantener el pipeline agnóstico y delegar la lógica específica de Azure/AWS/GCP en Terraform e IaC, usando un parámetro `cloud` como selector.

En este punto enfoqué el trabajo en ordenar el repositorio para que infraestructura, despliegue y configuración declarativa queden alineados y preparados para escenarios multinube, sin acoplar el pipeline a un proveedor específico.

Partí de tres pilares claros:

- `pipeline/`: definición del flujo de CI/CD en Azure DevOps.
- `iac/`: definición de infraestructura con Terraform segmentada por entorno (`dev`, `qa`, `prod`).
- `gitops/`: configuración declarativa de despliegue (Helm/Argo CD) con un `values-<env>.yaml` por entorno.

La idea es que el pipeline hable solo en términos de **entorno** y **versión**, mientras que los detalles de nube (Azure, AWS u otro proveedor) se resuelven en las capas de IaC y configuración, no en el YAML del pipeline.

#### Estructura del repositorio

Dejé la estructura organizada de la siguiente forma:

- `iac/dev`, `iac/qa`, `iac/prod`: cada carpeta contiene el `main.tf` y el `<env>.tfvars` con los parámetros propios de ese entorno. Aquí es donde se define el provider (por ejemplo `azurerm` hoy y, si se necesitara, `aws` u otro en el futuro).
- `gitops/envs/dev/values-dev.yaml`, `gitops/envs/qa/values-qa.yaml`, `gitops/envs/prod/values-prod.yaml`: estos archivos actúan como única fuente de verdad para la versión de la imagen (`image.tag`) y demás parámetros de despliegue por entorno.
- `pipeline/release/terraform-iac.yml`: plantilla de release que ejecuta Terraform apuntando a `iac/<env>` en función del entorno.
- `pipeline/release/jobs/Update-tag.yml`: job responsable de actualizar el `image.tag` en el values correspondiente según la rama (`develop` → dev, `release` → qa, tags → prod).

Con esta organización, el repositorio queda preparado para que la misma definición de pipeline pueda trabajar con uno o varios clusters, incluso en nubes distintas, sin tener que duplicar lógica.

#### Conexión con el pipeline de release

En el stage `ecosystem_integration` conecté estas piezas de la siguiente forma:

1. A partir de la rama, el pipeline determina el entorno objetivo:
   - `refs/heads/develop` → entorno `dev`
   - `refs/heads/release` → entorno `qa`
   - `refs/tags/*` → entorno `prod`
2. El template `terraform-iac.yml` se ejecuta contra `iac/<env>`, aplicando la infraestructura necesaria para ese entorno (hoy sobre AKS, pero el provider puede cambiar sin tocar el pipeline).
3. Una vez desplegada la aplicación (job `release_aks`), el job `update_tag` actualiza el campo `tag` dentro del `values-<env>.yaml` correspondiente en `gitops/envs/<env>/`.
4. Finalmente, el pipeline realiza el commit y push de ese cambio a Git. Argo CD u otra herramienta GitOps se encarga de observar el repositorio y aplicar la configuración al cluster que corresponda.

De esta manera, el pipeline no “sabe” si está desplegando en Azure, AWS o un cluster on-premise: solo declara qué versión debe ejecutarse en cada entorno. El acoplamiento a la nube se limita a los ficheros de Terraform (`iac/`) y a los templates de variables (`SatrackVars-*.yml`), que contienen los detalles del cluster y del proveedor.

#### Soporte multinube

El enfoque es multinube por diseño:

- Si mañana QA pasa de AKS a EKS, el cambio se limita a:
  - Ajustar el provider y recursos en `iac/qa`.
  - Actualizar las variables del cluster QA en el template correspondiente de `SatrackVars`.
  - (Opcionalmente) ajustar la Application de Argo CD para apuntar al nuevo cluster.
- El pipeline, el job `update_tag` y los `values-qa.yaml` seguirían funcionando exactamente igual, porque solo trabajan con entornos y tags, no con proveedores.

Esto permite:

- Reutilizar el mismo pipeline para distintos clusters y nubes.
- Mantener una única fuente de verdad por entorno en los `values-*.yaml`.
- Tener trazabilidad completa de qué versión se desplegó en cada entorno a través del historial de Git.

En resumen, en el punto 3.5 dejé el repositorio y el pipeline preparados para que IaC (Terraform) y GitOps trabajen juntos de forma coherente, y para que un cambio de nube no implique reescribir el pipeline, sino únicamente ajustar la capa de infraestructura y las variables de entorno.

---

## 3.6 Continuidad con el flujo existente

### Mantener el esqueleto build → test → security → release → deploy

Revisar `pipeline/main.yml` y validar que la estructura principal de stages se mantenga:

- build
- test
- security (solo si aplica)
- release
- deploy

Los nuevos bloques (GitOps, IaC, multinube, seguridad extendida) deben colgarse de estos stages sin introducir "saltos" nuevos en el flujo.

### Definir flags de modo extendido en pipeline/variables.yml

Añadir variables con valor por defecto `false`:

```yaml
enable_gitops: false
enable_iac: false
enable_security_scans: false
enable_multicloud: false
```

Reflejar estos flags también en `SatrackVars-*.yml` para poder activarlos por entorno y/o producto.

### Condicionar los bloques extendidos en pipeline/main.yml

En los jobs/stages que implementan:

- Seguridad avanzada (3.2)
- GitOps (3.3)
- IaC/Terraform (3.4)
- Lógica multinube (3.5)

Usar condiciones del estilo:

```yaml
- if: and(succeeded(), eq(variables['enable_security_scans'], 'true'))
- if: and(succeeded(), eq(variables['enable_gitops'], 'true'))
- if: and(succeeded(), eq(variables['enable_iac'], 'true'))
- if: and(succeeded(), eq(variables['enable_multicloud'], 'true'))
```

Con todos los flags en `false`, el pipeline debe comportarse igual que el original:
Entra por build, pasa por test y va a release → deploy sin ejecutar bloques nuevos.

### Definir claramente modo legacy vs. modo extendido

Documentar en pipeline/recomendaciones.md dos modos de operación:

Modo legacy:

Documentar en `pipeline/recomendaciones.md` dos modos de operación:

#### Modo legacy

- Todos los flags en `false`
- Mantiene semántica actual: build → test → deploy
- Conserva triggers (develop, release, master/main, tags), artefactos y modelo de despliegue existente (scripts/herramientas actuales)

#### Modo extendido

Activación selectiva por flags:

- `enable_security_scans` → activa stage/bloques de seguridad avanzada
- `enable_gitops` → activa la ruta GitOps (actualización de repositorio de manifests)
- `enable_iac` → ejecuta bloques de Terraform (validate/plan/apply según entorno)
- `enable_multicloud` → habilita la lógica específica para multinube

Dejar explícito que los cambios son opt-in y reversibles apagando los flags.

### Definir fases de adopción

Incluir en `pipeline/recomendaciones.md` un plan por fases:

#### Fase 1 – MVP

- Usar el template ya modificado pero con todos los flags en `false`
- Validar que el comportamiento es equivalente al pipeline original de la prueba

#### Fase 2 – Pilotos

- Seleccionar algunos servicios como early adopters
- Activar `enable_security_scans` y/o `enable_gitops` en entornos bajos (dev/test)
- Recoger feedback y ajustar templates/doc si es necesario

#### Fase 3 – Expansión

- Activar gradualmente los flags en el resto de servicios por ondas
- Mantener un plan de rollback simple: desactivar flags o apuntar al template previo si algo falla

### Compatibilidad con triggers, despliegue actual y credenciales

#### Triggers existentes

- Mantener la misma configuración de disparadores por rama/tag/PR
- Evitar cambios en la interfaz de uso del pipeline para los equipos actuales

#### Modelo de despliegue actual

- Aunque se active `enable_gitops`, definir un periodo en el que el despliegue legacy siga disponible (por ejemplo, protegido por otro flag o como fallback)

#### Gestión de credenciales

- Reutilizar service connections, key vaults y mecanismos actuales de credenciales
- Las nuevas integraciones (Terraform, Argo CD, registries multi-cloud) deben usar el mismo patrón de gestión de secretos, sin hardcodear credenciales en YAML