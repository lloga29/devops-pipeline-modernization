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