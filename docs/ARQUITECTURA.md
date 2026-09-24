# Arquitectura de LogiVerse Core

El proyecto usa una arquitectura por funcionalidades. La regla principal es
que la presentación captura y muestra datos, mientras que el dominio valida
los problemas, ejecuta los algoritmos y genera los pasos sin depender de
Flutter.

## Estructura actual

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                      # Widget raíz y configuración global
│   ├── app_theme.dart                # Temas claro y oscuro
│   └── app_theme_controller.dart     # Estado global del modo visual
├── features/
│   ├── assignment/
│   │   ├── domain/
│   │   │   ├── assignment_problem.dart
│   │   │   ├── assignment_result.dart
│   │   │   ├── assignment_solver.dart
│   │   │   └── optimization_mode.dart
│   │   └── presentation/
│   │       └── assignment_matrix_screen.dart
│   ├── northwest_corner/
│   │   ├── domain/
│   │   │   ├── transportation_problem.dart
│   │   │   ├── northwest_corner_result.dart
│   │   │   └── northwest_corner_solver.dart
│   │   └── presentation/
│   │       └── northwest_corner_screen.dart
│   └── johnson/
│       ├── domain/
│       │   ├── johnson_problem.dart
│       │   ├── johnson_result.dart
│       │   └── johnson_solver.dart
│       └── presentation/
│           └── johnson_matrix_screen.dart
├── models/                           # Modelos del editor gráfico heredado
├── screens/                          # Menú, navegación y editores heredados
└── shared/
    ├── persistence/                  # Importación y exportación JSON
    └── presentation/                 # Tarjetas, controles y grafo común
```

Las pruebas reflejan la misma organización dentro de `test/features/`.

La aplicación inicia directamente en `MenuPrincipalScreen`. Desde allí se
accede a los tres algoritmos principales, la ayuda, el cambio de tema y el
editor de grafos como herramienta adicional.

## Flujo de dependencias

```text
Pantalla → Problema de dominio → Solver → Resultado y pasos → Pantalla
```

El dominio no importa `material.dart`, widgets, archivos ni diálogos. Por eso
los algoritmos se pueden probar de forma aislada y reutilizar en otra interfaz.
Los objetos de resultado incluyen tanto la solución final como las matrices,
ecuaciones y decisiones necesarias para explicar el procedimiento.

`shared/presentation/algorithm_graph.dart` contiene el lienzo de nodos y
flechas reutilizado por los tres algoritmos. Las pantallas convierten sus
resultados de dominio en nodos y aristas; el componente compartido únicamente
se encarga de presentarlos y no ejecuta cálculos matemáticos.

## Responsabilidad de cada módulo

### Asignación

`AssignmentSolver` aplica el método Húngaro con la notación usada en clase.
Para maximizar construye `B = −A`; luego obtiene los vectores `α` y `β`,
reduce filas y columnas, cubre y ajusta ceros y calcula `Z` con los valores de
la matriz original.

### Esquina Noroeste

`NorthwestCornerSolver` recorre la tabla desde la esquina superior izquierda
para construir `G1`. Después calcula potenciales e indicadores, selecciona una
celda entrante, forma un circuito alternado `+α/−α` y genera nuevas matrices
hasta verificar la optimalidad. Cada iteración conserva las matrices anterior
y posterior, el circuito, `α`, los indicadores y el valor de `Z`.

### Johnson

`JohnsonSolver` implementa la regla clásica para dos máquinas: selecciona el
menor tiempo disponible, coloca el trabajo al inicio si pertenece a M1 o al
final si pertenece a M2 y luego calcula el cronograma y el *makespan*.

## Reglas para trabajar en equipo

1. Una modificación del algoritmo se hace en `features/<modulo>/domain` y
   debe incluir o actualizar una prueba.
2. Los cambios visuales se hacen en `presentation`; allí no se implementan
   las reglas matemáticas.
3. Los modelos de entrada y salida del algoritmo son inmutables.
4. El dominio no accede a `BuildContext`.
5. Los elementos comunes se extraen únicamente cuando dos o más pantallas
   realmente los comparten.
6. Antes de integrar cambios se ejecutan:

   ```powershell
   D:\flutter_sdk\bin\dart.bat analyze lib test
   D:\flutter_sdk\bin\flutter.bat test
   D:\flutter_sdk\bin\flutter.bat build web
   ```

## Distribución sugerida para tres integrantes

- Integrante 1: navegación, componentes compartidos y experiencia de usuario.
- Integrante 2: asignación por minimización/maximización y sus pruebas.
- Integrante 3: Esquina Noroeste, Johnson y sus pruebas.

Cada integrante debe trabajar en una rama distinta e integrar mediante revisión
para evitar ediciones simultáneas en las mismas pantallas.

## Código heredado

Los editores gráficos anteriores y la implementación de red de actividades
CPM/PERT siguen en `screens/` y en los archivos `activity_network_*`. Se
mantienen para no perder trabajo previo, pero no forman parte de las rutas
activas de Asignación, Esquina Noroeste ni Johnson. Una limpieza posterior
puede separarlos como otra funcionalidad o eliminarlos después de confirmar
que el docente no los requiere.
