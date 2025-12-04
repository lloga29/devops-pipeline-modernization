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


### Modelo de stacks para el pipeline de build (3.1)

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
