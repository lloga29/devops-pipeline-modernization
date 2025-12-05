# Análisis del pipeline actual

## 1. Contexto

El pipeline actual parte de un template orientado a aplicaciones .NET, con una estructura clásica de etapas `build → test → deploy`. Está pensado para centralizar la construcción y despliegue de servicios, pero todavía no incorpora de forma nativa requisitos modernos como GitOps, IaC, multinube ni controles de seguridad transversales.

Este análisis se enfoca en tres dimensiones:

- Capacidad de extensión a nuevos lenguajes y stacks.
- Nivel de integración con prácticas modernas (GitOps, IaC, DevSecOps).
- Riesgos de escalabilidad, seguridad y mantenibilidad a medio plazo.

## 2. Fortalezas

1. **Template único para servicios .NET**  
   Existe un pipeline base reutilizable para aplicaciones .NET, lo que reduce la duplicación de YAML y ofrece una experiencia homogénea para este stack.

2. **Estructura simple y fácil de entender**  
   La secuencia `build → test → deploy` es clara y reconocible para los equipos, facilitando la adopción inicial y el troubleshooting básico.

3. **Integración con la plataforma de CI existente**  
   El pipeline ya está integrado con agentes de build, manejo de artefactos y flujos de aprobación de la plataforma actual, por lo que no parte de cero en términos de automatización.

4. **Base aprovechable para evolución**  
   La existencia de un template y de un flujo ya aceptado por los equipos permite evolucionarlo de forma incremental, sin necesidad de introducir una herramienta de CI nueva.

## 3. Limitaciones

1. **Acoplamiento fuerte a .NET y al modelo actual de build**  
   El template está diseñado principalmente para .NET, lo que dificulta integrar de forma limpia nuevos lenguajes (Python, Angular, Java, etc.) sin ir añadiendo condicionales dispersos. Esto introduce riesgo de que aparezcan “variantes de pipeline” poco mantenibles.

2. **Seguridad tratada como un añadido, no como un estándar transversal**  
   El pipeline actual no incorpora de manera estructurada:
   - SAST (SonarQube) con quality gates obligatorios.  
   - Escaneo de dependencias (Trivy FS, OWASP Dependency Check).  
   - Escaneo de imágenes de contenedor.  
   - Validación de políticas (OPA/Kyverno/Conftest).  
   Tampoco define criterios claros para fallar el pipeline ante vulnerabilidades críticas o configuraciones inseguras.

3. **Ausencia de modelo GitOps**  
   El despliegue está orientado a acciones directas sobre los entornos (scripts, tasks, etc.), en lugar de actualizar un repositorio de manifiestos/Helm y delegar la reconciliación en Argo CD u otra herramienta GitOps. Esto limita:
   - La trazabilidad de qué versión está desplegada en cada entorno.  
   - La facilidad de rollback declarativo.  
   - La auditabilidad de los cambios.

4. **Infraestructura fuera del flujo declarativo (sin IaC integrado)**  
   La infraestructura (redes, clusters, balanceadores, bases de datos, etc.) no forma parte del pipeline como código versionado con Terraform u otra herramienta IaC. Esto genera:
   - Cambios manuales o semimanuales en infraestructura.  
   - Poca sincronización entre la versión de la app y el estado de la plataforma.  
   - Dificultad para reproducir entornos y automatizar escenarios multinube.

5. **Enfoque implícito single-cloud**  
   El diseño actual no abstrae el despliegue por proveedor cloud. La lógica está fuertemente acoplada al contexto actual (una nube y un tipo de cluster), lo que dificulta:
   - Publicar el mismo componente en Azure y AWS con el mismo pipeline.  
   - Reutilizar plantillas y módulos de infraestructura entre nubes.  
   - Gestionar de forma homogénea escenarios híbridos u on-prem.

6. **Escasa gobernanza sobre cambios complejos**  
   Al no existir un vínculo claro entre:
   - código de aplicación,  
   - cambios de infraestructura,  
   - y manifiestos declarativos GitOps,  
   se complica la gobernanza del ciclo de vida: quién cambió qué, cuándo y con qué impacto en cada entorno.

## 4. Riesgos principales

1. **Riesgo de escalabilidad operativa**
   - Cada nuevo lenguaje o arquitectura tiende a introducir excepciones y bloques condicionales adicionales en el YAML.  
   - El crecimiento no controlado de variantes de pipeline complica el soporte y la estandarización.

2. **Riesgo de seguridad y cumplimiento**
   - Sin quality gates obligatorios, vulnerabilidades críticas o secretos expuestos pueden llegar a entornos superiores sin ser bloqueados.  
   - La ausencia de un modelo sistemático de escaneo (código, dependencias, imágenes, manifiestos, runtime) dificulta alinearse con requisitos de seguridad corporativos.

3. **Riesgo de mantenibilidad**
   - El acoplamiento entre lógica de negocio y detalles de despliegue (scripts específicos, lógica por entorno) aumenta la carga de mantenimiento.  
   - Cambios estructurales (por ejemplo, introducir GitOps o multinube) son costosos si no se separan responsabilidades en capas (CI, IaC, GitOps).

4. **Riesgo de vendor lock-in**
   - Al no existir una capa de abstracción para IaC y despliegue multinube, la estrategia queda ligada a un proveedor concreto.  
   - Migrar o extender el pipeline a otro cloud implica reescribir buena parte de la lógica actual.

## 5. Cómo responde la propuesta 3.1–3.6

A partir de este diagnóstico, la propuesta de mejora que desarrollé en los puntos 3.1–3.6 aborda las limitaciones anteriores de forma estructurada:

1. **Extensión a nuevos lenguajes (3.1)**  
   - Se introduce un parámetro `stack` y una convención de templates (`jobs/<stack>-job.yml`) para desacoplar la lógica de build por lenguaje del pipeline principal.  
   - Esto permite añadir Python, Angular y nuevos stacks sin modificar el stage principal de build ni multiplicar pipelines.

2. **Seguridad y quality gates integrados (3.2)**  
   - Se define un modelo de seguridad por capas (secret scanning, SAST, SCA, image scanning, policy-as-code y seguridad en runtime con NeuVector).  
   - Se establecen criterios explícitos para romper el pipeline ante vulnerabilidades críticas, fallos de quality gate o violaciones de políticas.

3. **Modelo GitOps con Argo CD + Argo Rollouts + Kargo (3.3)**  
   - El despliegue directo se sustituye por la actualización de un repositorio GitOps (Helm/Argo CD), donde Git es la única fuente de verdad.  
   - Argo Rollouts gestiona despliegues canary/blue-green y Kargo orquesta la promoción entre entornos en base a condiciones objetivas (estado Healthy/Synced, ausencia de errores, etc.).

4. **Integración de IaC con Terraform (3.4)**  
   - La infraestructura se gestiona como código, con módulos reutilizables, backends remotos y flujos `validate → plan → apply` gobernados por el pipeline.  
   - Los outputs de Terraform alimentan la configuración GitOps (values.yaml) para mantener alineados plataforma y despliegue.

5. **Estrategia multinube parametrizada (3.5)**  
   - El pipeline se mantiene único y agnóstico de nube en CI; la variabilidad se lleva a IaC (módulos por proveedor) y GitOps (rutas y repos por cloud/entorno).  
   - Parámetros como `CLOUD`, `ENVIRONMENT` y `CLUSTER_TARGET` permiten decidir si se despliega en Azure, AWS u otros destinos con la misma lógica base.

6. **Continuidad del flujo existente y adopción gradual (3.6)**  
   - Se conservan los stages `build → test → deploy` y se introducen flags (`enable_gitops`, `enable_iac`, `enable_security_scans`, `enable_multicloud`) para mantener un “modo legacy” y un “modo extendido”.  
   - La adopción se plantea por fases, empezando por pilotos y expandiendo progresivamente a más equipos, reduciendo el riesgo de ruptura del flujo actual.

En conjunto, el análisis del pipeline actual y la propuesta 3.1–3.6 convergen en un pipeline modular, estándar y preparado para seguridad, GitOps, IaC y multinube, sin perder compatibilidad con la forma de trabajar que ya tienen los equipos.
