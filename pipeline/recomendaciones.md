# <center> Oportunidades de mejora. </center>

En la creación de las plantillas se encontraron varios aspectos que podrían mejorarse en el futuro en los pipeline como código.

* ## Uso de Helm para despliegues en AKS.
Con esta herramienta se puede hacer la gestión de despliegues en los diferentes ambientes.
* ## Definición de pruebas obligatorias.
Se recomienda definir el tipo de pruebas que todos los proyectos deban implementar en la ejecución del pipeline para garantizar una mayor seguridad y calidad de las aplicaciones.
* ## Aplicación de políticas a los repositorios.
Dentro de las configuraciones que deben realizarse a los repositorios que implementen las plantillas, se debe:
1. Restringir los cambios en el código en las ramas develop, release y master.
2. Definir grupos de aprobadores para los pull requests en cada paso.

* ##Pipeline de creación de repositorio.
Crear un pipeline que se encargue de crear los repositorios para nuevos proyectos con la estructura base de las carpetas y que se encargue de aplicar las políticas definidas para los repositorios.
* ## Evolución del pipeline.
Se recomienda evolucionar el pipeline incluyendo:
1. Pruebas de seguridad
2. Análisis de contenedores
3. Compliance Testing
4. Pull request automáticos.
5. Rollback y pruebas de humo.


### 3.1 Modelo de stacks para el pipeline de build

El template principal `pipeline/main.yml` expone un parámetro `stack` que representa el stack tecnológico completo (lenguaje + tipo de build). En lugar de seguir añadiendo condiciones `if` por lenguaje, el pipeline delega en un router de build (`pipeline/build/development-integration.yml`) que invoca dinámicamente `jobs/<stack>-job.yml`.

Stacks soportados:
- `netcore` → `jobs/netcore-job.yml`
- `java-gradle` → `jobs/java-gradle-job.yml`
- `java-maven` → `jobs/java-maven-job.yml`
- `python` → `jobs/python-job.yml`
- `angular` → `jobs/angular-job.yml`

Para añadir un nuevo stack, basta con:
1. Agregar el nuevo valor en `parameters.stack.values` en `pipeline/main.yml`.
2. Crear el archivo `pipeline/build/jobs/<stack>-job.yml` con la lógica de build y tests correspondiente.

### 3.2 Seguridad y quality gates en el stage de Technical Excellence

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


### 3.3 Modelo GitOps con Argo CD / Argo Rollouts / Kargo

En lugar de que el pipeline despliegue directamente al clúster, el modelo propuesto para 3.3 es GitOps: el pipeline actualiza la declaración de estado en un repositorio (o carpeta) de configuración y una herramienta como Argo CD se encarga de sincronizar los cambios al clúster.

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

En este ejercicio no implemento toda la integración real con Argo CD ni con Kargo, pero dejo clara la estructura de GitOps, el punto donde el pipeline actualiza la “verdad” (`values-*.yaml`) y cómo el modelo se extiende a múltiples entornos de forma declarativa.


* ## 3.4 Integración de IaC con Terraform y acople a GitOps

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
  atp/
    main.tf
    atp.tfvars
  prod/
    main.tf
    prod.tfvars
