import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'futuristic_surface.dart';

/// Encabezado y superficie comunes a todos los módulos de algoritmos.
class AlgorithmScaffold extends StatelessWidget {
  const AlgorithmScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.body,
    this.actions = const [],
    this.accent = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final Widget body;
  final List<Widget> actions;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: actions,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: FuturisticBackground(
        accent: accent,
        child: SafeArea(child: body),
      ),
    );
  }
}

/// Conserva el lienzo a la izquierda en escritorio y apila el panel en móvil.
/// Ambos hijos reciben límites de altura para sus listas y visualizaciones.
class AlgorithmWorkspace extends StatelessWidget {
  const AlgorithmWorkspace({
    super.key,
    required this.canvas,
    this.panel,
    this.isEmpty = false,
    this.emptyIcon = Icons.hub_outlined,
    this.emptyTitle = 'Construye tu primera red',
    this.emptyDescription = 'Haz clic en el lienzo para crear un nodo. Selecciona dos nodos para conectarlos.',
    this.accent = AppColors.primary,
  });

  final Widget canvas;
  final Widget? panel;
  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasArea = Stack(
          fit: StackFit.expand,
          children: [
            canvas,
            if (isEmpty)
              IgnorePointer(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            emptyIcon,
                            color: accent.withValues(alpha: 0.7),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            emptyTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            emptyDescription,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
        if (panel == null) return canvasArea;
        final panelSurface = ColoredBox(
          color: AppColors.surface,
          child: panel!,
        );
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: canvasArea),
              const VerticalDivider(width: 1),
              SizedBox(width: 460, child: panelSurface),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: canvasArea),
            const Divider(height: 1),
            Expanded(child: panelSurface),
          ],
        );
      },
    );
  }
}

class AlgorithmPanelSection extends StatelessWidget {
  const AlgorithmPanelSection({
    super.key,
    required this.title,
    required this.child,
    this.highlighted = false,
  });

  final String title;
  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primarySoft : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Acciones del lienzo con espacio para envolver el contenido en pantallas pequeñas.
class AlgorithmCanvasControls extends StatelessWidget {
  const AlgorithmCanvasControls({
    super.key,
    required this.onClear,
    required this.nodeCount,
    required this.connectionCount,
  });

  final VoidCallback onClear;
  final int nodeCount;
  final int connectionCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Limpiar lienzo'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Nodos: $nodeCount • Conexiones: $connectionCount',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
