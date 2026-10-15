# Comparación e integración del avance del equipo

Fecha: 15 de octubre de 2026.

## Versiones comparadas y carpetas

- Tu versión local de partida: `712d8be` de `migusaper1530/app-grafos`, rama `merge-shell-sort`.
- Avance de tu compañero: `fdb18647b3126949358f350eb7b683752bbc6e22`, rama `main` de [jesusademar/algoritmos-app](https://github.com/jesusademar/algoritmos-app).
- Tu proyecto actualizado: `/home/miguel/Documents/universidad/Analisis de algoritmos/app-grafos/app-grafos`.
- Descarga separada del compañero: `/home/miguel/Documents/universidad/Analisis de algoritmos/algoritmos-app-companero`.
- Se incorporó también el historial de `origin/main` hasta `46aa04e`, que ya contenía la configuración anterior de GitHub Pages.

La comparación se hizo entre los archivos fuente de ambos repositorios,
no únicamente entre sus páginas compiladas. Tu repositorio y su remoto se
conservan. El clon del compañero mantiene su propio `.git` y su propio remoto.
La versión local anterior sigue disponible en el historial, en `712d8be`.

## Diferencias funcionales y resultado

| Área | Tu versión anterior | Avance del compañero | Versión integrada |
| --- | --- | --- | --- |
| Árboles binarios | No había módulo de árboles | Inserción, números aleatorios, movimiento de nodos, recorridos y reconstrucción con dos recorridos | Se incorporó el módulo completo, con guardar/cargar JSON y su manual |
| Carrera de ordenamientos | Visualizaciones individuales de cuatro algoritmos | Comparación simultánea de Selection, Insertion, Merge y Shell con una entrada común y línea de tiempo | Se incorporó la carrera usando los algoritmos locales conservados |
| Ejemplos y catálogo | Inicio educativo y cinco módulos | Ejemplos listos para seis módulos, búsqueda y navegación centralizada | Se incorporaron los ejemplos y el catálogo compartido |
| Procedimiento matemático | Resultado y asignaciones finales | Detalle de matrices, restricciones, búsqueda y distribución de transporte | Se incorporaron los procedimientos de Asignación y Transporte |
| Matriz ficticia | Filas/columnas de costo cero resaltadas y explicadas | Modelo cuadrado compartido y asignaciones ficticias incluidas en el resultado | Se combina el modelo compartido con el resaltado amarillo y la explicación local; el costo del ejemplo sigue siendo 7 |
| Johnson / actividades | Cálculo de tiempos y ruta crítica | Validaciones de bucles, ciclos y conexiones inversas | Se incorporaron validaciones y mensajes, manteniendo el módulo CPM/PERT |
| Merge Sort | Implementación propia con pasos de división, selección auxiliar y escritura | Otra implementación equivalente de mezcla | Se conservó la implementación local y sus regresiones |
| Shell Sort | Saltos de Knuth: 1, 4, 13, … | Saltos n/2, n/4, … | Se conservó Knuth y su cota O(n^(3/2)); se ajustaron las explicaciones y la carrera a esa variante |
| JSON de grafos | Descarga web corregida y guardado directo en Descargas en escritorio | Servicio común, selector de destino, vista previa que actualiza el nombre, cancelación y errores recuperables | Se usa un servicio común con descarga Blob/XFile en web, selector de destino en escritorio y guardado móvil; se conserva la verificación UTF-8 |
| JSON de ordenamiento y árboles | No había sesiones de estos módulos | Documentos JSON propios con validación y recuperación del estado | Se incorporaron ambos formatos; los archivos existentes de grafos siguen usando las mismas claves |
| Organización | Pantallas en `lib/screens`, dominio separado | Pantallas y componentes dentro de cada módulo, catálogo y modelos compartidos | Se adoptó la organización nueva y se conservaron los exports de compatibilidad en las rutas anteriores |
| Publicación | El workflow estaba en `main` remoto, pero no en la rama local de trabajo | Workflow genérico que obtiene la ruta de Pages | Se incluye el workflow en la integración y la guía apunta a la cuenta y repositorio de Miguel |

La carrera muestra turnos de animación y operaciones. Sus turnos no son una
medición de velocidad real de los algoritmos.

## Tamaño de la comparación

Antes de integrar, los archivos Dart eran:

| Carpeta | Tu versión | Compañero | Nuevos en el avance | Archivos comunes con diferencias |
| --- | ---: | ---: | ---: | ---: |
| `lib/` | 44 | 84 | 41 | 37 |
| `test/` | 16 | 28 | 21 | 7 |

Estos conteos describen los dos snapshots originales y excluyen archivos
como `.DS_Store`, cachés y compilaciones. La integración añade adaptaciones y
mueve las regresiones locales a las carpetas de sus módulos.

## Decisiones para conservar el trabajo local

1. Se conservaron `SortingSolver` y la información de complejidad de la versión local. La carrera y los archivos nuevos reutilizan ese mismo dominio.
2. Se mantuvieron las pruebas de Merge y Shell, reubicadas en `test/features/sorting/domain/`.
3. La matriz de Asignación toma los costos ficticios de `AssignmentProblem.toSquare()`, muestra todos los elementos necesarios y conserva el resaltado y la explicación. El resultado ahora también identifica la asignación ficticia de costo cero.
4. Las regresiones de la matriz verifican casos 2×3, 3×2, 1×3, 3×1 y 2×2, con texto ampliado en móvil y escritorio. Las rutas reales ausentes continúan mostrándose como `-`.
5. Los elementos ficticios no se agregan a los nodos reales ni al JSON del editor. Se verificó la conservación de los cinco nodos y seis conexiones del ejemplo.
6. `GraphFileService` reemplaza el exportador anterior. En web conserva la descarga comprobada con `XFile`; en escritorio usa `file_selector` para escoger destino, incluida la plataforma Linux; en Android/iOS utiliza `file_saver`.
7. Las regresiones de Chrome comprueban nombre, tipo MIME, contenido UTF-8 y cierre del diálogo de descarga. También se verifican cancelación y recuperación de errores del nuevo formulario.
8. Se actualizaron README, arquitectura y publicación, con los créditos del equipo y el destino de GitHub de Miguel.

## Verificación

- El clon original del compañero pasó sus 124 pruebas antes de integrar.
- La versión integrada pasó las 143 pruebas de la app.
- Las 27 pruebas seleccionadas de Chrome pasaron, incluyendo archivos, árboles, carrera y matriz ficticia.
- El análisis final se ejecuta sin incidencias.
- La compilación de producción se verifica con `flutter build web --release --base-href "/app-grafos/"`.

Las pruebas de guardado nativo usan escritores sustituidos para simular
éxito, cancelación y errores. La comprobación del navegador verifica los enlaces
y el contenido real del Blob generado. La validación de compilación de esta
entrega corresponde a Flutter Web.

## Publicar en tu GitHub y actualizar la web

La integración se guarda en `merge-shell-sort`. Para que aparezca en la web,
hay que actualizar `main`, que es la rama que dispara el despliegue.
Consulta [la guía con los comandos completos](PUBLICAR_EN_GITHUB.md).

El destino final es [migusaper1530.github.io/app-grafos](https://migusaper1530.github.io/app-grafos/).
No se publicó automáticamente: los comandos quedan preparados para que tú
realices el push manualmente, como pediste.
