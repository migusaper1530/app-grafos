import 'package:flutter/material.dart';

import '../app/app_theme_controller.dart';
import '../features/assignment/presentation/assignment_matrix_screen.dart';
import '../features/johnson/presentation/johnson_matrix_screen.dart';
import '../features/northwest_corner/presentation/northwest_corner_screen.dart';
import 'grafo_screen.dart' as grafo;

class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  static const _modules = [
    _ModuleInfo(
      number: '01',
      title: 'Método de Asignación',
      category: 'Método Húngaro',
      description: 'Relaciona recursos con tareas para obtener el costo mínimo o el beneficio máximo.',
      icon: Icons.assignment_turned_in_rounded,
      color: Color(0xFF6366F1),
      tags: ['Min / Max', 'Matriz', 'Nodos', 'Paso a paso'],
      destination: _Destination.assignment,
      preview: _PreviewKind.assignment,
    ),
    _ModuleInfo(
      number: '02',
      title: 'Esquina Noroeste',
      category: 'Problema de transporte',
      description: 'Construye G1 desde la esquina noroeste y la optimiza mediante circuitos con α.',
      icon: Icons.grid_view_rounded,
      color: Color(0xFF0EA5E9),
      tags: ['Min / Max', 'G1, G2…', '+α / −α', 'Nodos'],
      destination: _Destination.northwest,
      preview: _PreviewKind.northwest,
    ),
    _ModuleInfo(
      number: '03',
      title: 'Algoritmo de Johnson',
      category: 'Programación de trabajos',
      description: 'Ordena trabajos en dos máquinas y minimiza el tiempo total de producción.',
      icon: Icons.schedule_rounded,
      color: Color(0xFFF59E0B),
      tags: ['M1 + M2', 'Makespan', 'Nodos', 'Cronograma'],
      destination: _Destination.johnson,
      preview: _PreviewKind.johnson,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeController = AppThemeScope.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF64748B);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 24,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LogiVerse Core',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Investigación de Operaciones',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: mutedColor, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('help-button'),
            tooltip: 'Ayuda',
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const ValueKey('theme-toggle'),
            tooltip: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
            onPressed: themeController.toggle,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroBanner(isDark: isDark),
                  const SizedBox(height: 34),
                  _SectionHeading(
                    eyebrow: 'ALGORITMOS PRINCIPALES',
                    title: 'Elige un método para comenzar',
                    description: 'Ingresa los datos, resuelve el problema y estudia su procedimiento en matriz o nodos.',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1000
                          ? 3
                          : constraints.maxWidth >= 640
                          ? 2
                          : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _modules.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          mainAxisExtent: 390,
                        ),
                        itemBuilder: (context, index) => _ModuleCard(
                          module: _modules[index],
                          onTap: () =>
                              _openModule(context, _modules[index].destination),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  _SectionHeading(
                    eyebrow: 'HERRAMIENTAS ADICIONALES',
                    title: 'Editor de redes y grafos',
                    description: 'Conservamos el editor visual como herramienta complementaria del proyecto.',
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  const SizedBox(height: 16),
                  _GraphToolCard(
                    onTap: () => _openModule(context, _Destination.graph),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openModule(BuildContext context, _Destination destination) {
    final Widget screen = switch (destination) {
      _Destination.assignment => const AssignmentMatrixScreen(),
      _Destination.northwest => const NorthwestCornerScreen(),
      _Destination.johnson => const JohnsonMatrixScreen(),
      _Destination.graph => const grafo.GrafoScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _HelpDialog(),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF312E81), Color(0xFF1E1B4B)]
              : const [Color(0xFF4F46E5), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336366F1),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 18,
          children: [
            SizedBox(
              width: constraints.maxWidth > 650 ? 650 : constraints.maxWidth,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suite de optimización',
                    style: TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Resuelve, visualiza y comprende cada algoritmo.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tres métodos académicos con matrices editables, procedimiento completo y representación por nodos.',
                    style: TextStyle(color: Colors.white70, height: 1.45),
                  ),
                ],
              ),
            ),
            Container(
              width: constraints.maxWidth < 760 ? constraints.maxWidth : 250,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.groups_2_outlined, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proyecto académico',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          'Equipo de 3 integrantes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.textColor,
    required this.mutedColor,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: mutedColor, height: 1.4)),
      ],
    );
  }
}

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final _ModuleInfo module;
  final VoidCallback onTap;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF121214) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF64748B);

    return Semantics(
      button: true,
      label: 'Abrir ${widget.module.title}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _highlighted = true),
        onExit: (_) => setState(() => _highlighted = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _highlighted ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _highlighted
                  ? widget.module.color.withValues(alpha: 0.75)
                  : isDark
                  ? Colors.white12
                  : const Color(0xFFE2E8F0),
              width: _highlighted ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _highlighted
                    ? widget.module.color.withValues(alpha: 0.16)
                    : const Color(0x100F172A),
                blurRadius: _highlighted ? 24 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('module-${widget.module.destination.name}'),
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(22),
              onFocusChange: (value) => setState(() => _highlighted = value),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: widget.module.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            widget.module.number,
                            style: TextStyle(
                              color: widget.module.color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          widget.module.icon,
                          color: widget.module.color,
                          size: 27,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ModulePreview(
                      kind: widget.module.preview,
                      color: widget.module.color,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.module.category,
                      style: TextStyle(
                        color: widget.module.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.module.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.module.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in widget.module.tags)
                          _FeatureTag(
                            text: tag,
                            color: widget.module.color,
                            isDark: isDark,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Abrir método',
                          style: TextStyle(
                            color: widget.module.color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: widget.module.color,
                          size: 19,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  const _FeatureTag({
    required this.text,
    required this.color,
    required this.isDark,
  });

  final String text;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? color.withValues(alpha: 0.95) : color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ModulePreview extends StatelessWidget {
  const _ModulePreview({
    required this.kind,
    required this.color,
    required this.isDark,
  });

  final _PreviewKind kind;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: CustomPaint(
        painter: _PreviewPainter(kind: kind, color: color),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  const _PreviewPainter({required this.kind, required this.color});

  final _PreviewKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final node = Paint()..color = color;
    final softNode = Paint()..color = color.withValues(alpha: 0.28);

    switch (kind) {
      case _PreviewKind.assignment:
        final left = [0.24, 0.5, 0.76];
        final right = [0.3, 0.7];
        for (var index = 0; index < left.length; index++) {
          final from = Offset(size.width * 0.2, size.height * left[index]);
          final to = Offset(
            size.width * 0.8,
            size.height * right[index % right.length],
          );
          canvas.drawLine(from, to, line);
          canvas.drawCircle(from, 7, node);
        }
        for (final y in right) {
          canvas.drawCircle(Offset(size.width * 0.8, size.height * y), 8, node);
        }
      case _PreviewKind.northwest:
        const gap = 5.0;
        final cell = (size.height - 24 - gap * 2) / 3;
        final startX = (size.width - cell * 3 - gap * 2) / 2;
        for (var row = 0; row < 3; row++) {
          for (var column = 0; column < 3; column++) {
            final rect = RRect.fromRectAndRadius(
              Rect.fromLTWH(
                startX + column * (cell + gap),
                12 + row * (cell + gap),
                cell,
                cell,
              ),
              const Radius.circular(4),
            );
            canvas.drawRRect(rect, row == 0 && column == 0 ? node : softNode);
          }
        }
      case _PreviewKind.johnson:
        final topY = size.height * 0.3;
        final bottomY = size.height * 0.7;
        final xs = [0.18, 0.4, 0.62, 0.84];
        for (var index = 0; index < xs.length; index++) {
          final top = Offset(size.width * xs[index], topY);
          final bottom = Offset(size.width * xs[index], bottomY);
          canvas.drawLine(top, bottom, line);
          if (index > 0) {
            canvas.drawLine(
              Offset(size.width * xs[index - 1], topY),
              top,
              line,
            );
            canvas.drawLine(
              Offset(size.width * xs[index - 1], bottomY),
              bottom,
              line,
            );
          }
          canvas.drawCircle(top, 6, node);
          canvas.drawCircle(bottom, 6, softNode);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}

class _GraphToolCard extends StatelessWidget {
  const _GraphToolCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF64748B);
    const accent = Color(0xFFEC4899);

    return Material(
      color: isDark ? const Color(0xFF121214) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const ValueKey('module-graph'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.hub_outlined, color: accent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Redes y Grafos',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crea nodos y conexiones en el editor visual heredado.',
                      style: TextStyle(color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpDialog extends StatelessWidget {
  const _HelpDialog();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.help_outline_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ayuda rápida',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cómo utilizar la aplicación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const _HelpStep(
                number: '1',
                title: 'Selecciona un algoritmo',
                description: 'Abre Asignación, Esquina Noroeste o Johnson desde su tarjeta.',
              ),
              const _HelpStep(
                number: '2',
                title: 'Completa la matriz o tabla',
                description: 'Puedes modificar el ejemplo incluido o limpiar los valores para crear uno nuevo.',
              ),
              const _HelpStep(
                number: '3',
                title: 'Calcula la solución',
                description: 'El resultado muestra el valor final, las selecciones y todas las ecuaciones utilizadas.',
              ),
              const _HelpStep(
                number: '4',
                title: 'Cambia la visualización',
                description: 'Usa Matriz/Tabla y Nodos para estudiar la misma solución de dos formas.',
              ),
              const SizedBox(height: 12),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 12),
              const Text(
                '¿Qué resuelve cada módulo?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const _HelpModule(
                color: Color(0xFF6366F1),
                title: 'Asignación',
                description: 'Encuentra la relación óptima entre recursos y tareas mediante el método Húngaro.',
              ),
              const _HelpModule(
                color: Color(0xFF0EA5E9),
                title: 'Esquina Noroeste',
                description: 'Construye la solución inicial y la mejora con indicadores y circuitos +α/−α.',
              ),
              const _HelpModule(
                color: Color(0xFFF59E0B),
                title: 'Johnson',
                description: 'Ordena trabajos en dos máquinas para minimizar el makespan.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Entendido'),
        ),
      ],
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              number,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpModule extends StatelessWidget {
  const _HelpModule({
    required this.color,
    required this.title,
    required this.description,
  });

  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleInfo {
  const _ModuleInfo({
    required this.number,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    required this.tags,
    required this.destination,
    required this.preview,
  });

  final String number;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final _Destination destination;
  final _PreviewKind preview;
}

enum _Destination { assignment, northwest, johnson, graph }

enum _PreviewKind { assignment, northwest, johnson }
