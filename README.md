# LogiVerse Core

Aplicación académica desarrollada con Flutter para resolver y explicar
problemas de investigación de operaciones.

## Funcionalidades

- Método de asignación Húngaro por minimización y maximización.
- Esquina Noroeste con optimización de transporte por ciclos `+α/−α`.
- Regla clásica de Johnson para ordenar trabajos en dos máquinas.
- Matrices editables, resultado final y procedimiento paso a paso.
- Vista intercambiable de matriz/tabla y nodos para las tres soluciones.
- Menú inicial adaptable, guía de ayuda y selector de modo claro/oscuro.
- Transformaciones de matrices, selecciones y ecuaciones usadas por cada
  algoritmo.
- Editor visual de grafos heredado e importación/exportación en formato JSON.
- Ejecución en Android y navegador web.

## Arquitectura

La aplicación está organizada por funcionalidades. Cada algoritmo separa sus
reglas de dominio de su interfaz:

```text
lib/
├── app/                              # Configuración y control global del tema
├── features/
│   ├── assignment/
│   │   ├── domain/                   # Método Húngaro
│   │   └── presentation/             # Matriz, resultado y pasos
│   ├── northwest_corner/
│   │   ├── domain/                   # Problema de transporte y solver
│   │   └── presentation/             # Matriz, resultado y pasos
│   └── johnson/
│       ├── domain/                   # Regla de Johnson para dos máquinas
│       └── presentation/             # Tabla, secuencia y cronograma
├── models/                           # Modelos del editor gráfico heredado
├── screens/                          # Menú, navegación y pantallas heredadas
└── shared/
    ├── persistence/                  # Formato JSON compartido
    └── presentation/                 # Componentes visuales reutilizables
```

La explicación completa está en
[`docs/ARQUITECTURA.md`](docs/ARQUITECTURA.md).

## Ejecutar el proyecto

```powershell
flutter pub get
flutter run -d chrome
```

Para ejecutar las verificaciones:

```powershell
dart analyze lib test
flutter test
flutter build web
```

## Métodos implementados

- **Asignación:** aplica el procedimiento Húngaro usado en clase, incluyendo
  `B = −A` para maximización, vectores `α` y `β`, matrices reducidas, ceros
  independientes y el cálculo final de `Z`.
- **Esquina Noroeste:** construye `G1`, calcula indicadores con potenciales,
  forma circuitos cerrados `+α/−α` y genera `G2`, `G3`… hasta comprobar la
  solución óptima de minimización o maximización.
- **Johnson:** ordena trabajos para dos máquinas, muestra cada selección y
  calcula los tiempos de inicio, finalización, ociosidad y *makespan*.

Después de resolver, cada módulo permite alternar a **Nodos**. Asignación y
Esquina Noroeste usan grafos bipartitos; Johnson muestra el flujo ordenado de
cada trabajo por M1 y M2 con sus intervalos de ejecución.

Los archivos antiguos de red de actividades CPM/PERT se conservan como código
heredado, pero la opción **Johnson** del menú abre el método clásico de dos
máquinas.
