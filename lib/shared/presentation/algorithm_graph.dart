import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AlgorithmSolutionView { table, nodes }

class AlgorithmViewSelector extends StatelessWidget {
  const AlgorithmViewSelector({
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
    this.tableLabel = 'Matriz',
    super.key,
  });

  final AlgorithmSolutionView value;
  final ValueChanged<AlgorithmSolutionView> onChanged;
  final String keyPrefix;
  final String tableLabel;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AlgorithmSolutionView>(
      segments: [
        ButtonSegment(
          value: AlgorithmSolutionView.table,
          icon: const Icon(Icons.grid_view_rounded),
          label: Text(tableLabel, key: ValueKey('$keyPrefix-table')),
        ),
        ButtonSegment(
          value: AlgorithmSolutionView.nodes,
          icon: const Icon(Icons.hub_outlined),
          label: Text('Nodos', key: ValueKey('$keyPrefix-nodes')),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class AlgorithmGraphNode {
  const AlgorithmGraphNode({
    required this.id,
    required this.label,
    required this.position,
    required this.color,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;
  final Offset position;
  final Color color;
}

class AlgorithmGraphEdge {
  const AlgorithmGraphEdge({
    required this.from,
    required this.to,
    required this.label,
    required this.color,
    this.dashed = false,
  });

  final String from;
  final String to;
  final String label;
  final Color color;
  final bool dashed;
}

class AlgorithmNodeGraph extends StatelessWidget {
  const AlgorithmNodeGraph({
    required this.nodes,
    required this.edges,
    required this.description,
    this.height = 390,
    this.minimumWidth = 720,
    super.key,
  });

  final List<AlgorithmGraphNode> nodes;
  final List<AlgorithmGraphEdge> edges;
  final String description;
  final double height;
  final double minimumWidth;

  static const _nodeWidth = 112.0;
  static const _nodeHeight = 70.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF475569)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : minimumWidth;
            final canvasWidth = math.max(minimumWidth, availableWidth);
            return Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: canvasWidth,
                  height: height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _AlgorithmGraphPainter(
                            nodes: nodes,
                            edges: edges,
                          ),
                        ),
                      ),
                      for (final node in nodes)
                        Positioned(
                          left: node.position.dx * canvasWidth - _nodeWidth / 2,
                          top: node.position.dy * height - _nodeHeight / 2,
                          width: _nodeWidth,
                          height: _nodeHeight,
                          child: _GraphNodeCard(node: node),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GraphNodeCard extends StatelessWidget {
  const _GraphNodeCard({required this.node});

  final AlgorithmGraphNode node;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${node.label}${node.subtitle == null ? '' : ', ${node.subtitle}'}',
      child: Container(
        key: ValueKey('graph-node-${node.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            node.color.withValues(alpha: 0.12),
            Colors.white,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: node.color, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x180F172A),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              node.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: node.color, fontWeight: FontWeight.w900),
            ),
            if (node.subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                node.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlgorithmGraphPainter extends CustomPainter {
  const _AlgorithmGraphPainter({required this.nodes, required this.edges});

  final List<AlgorithmGraphNode> nodes;
  final List<AlgorithmGraphEdge> edges;

  @override
  void paint(Canvas canvas, Size size) {
    final positions = {
      for (final node in nodes)
        node.id: Offset(
          node.position.dx * size.width,
          node.position.dy * size.height,
        ),
    };

    for (final edge in edges) {
      final rawStart = positions[edge.from];
      final rawEnd = positions[edge.to];
      if (rawStart == null || rawEnd == null) continue;

      final vector = rawEnd - rawStart;
      final distance = vector.distance;
      if (distance == 0) continue;
      final direction = vector / distance;
      final trim = math.min(58.0, distance * 0.22);
      final start = rawStart + direction * trim;
      final end = rawEnd - direction * trim;
      final paint = Paint()
        ..color = edge.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (edge.dashed) {
        _drawDashedLine(canvas, start, end, paint);
      } else {
        canvas.drawLine(start, end, paint);
      }
      _drawArrow(canvas, end, direction, edge.color);
      _drawLabel(canvas, (start + end) / 2, edge.label, edge.color);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final vector = end - start;
    final distance = vector.distance;
    if (distance == 0) return;
    final direction = vector / distance;
    const dash = 8.0;
    const gap = 5.0;
    for (var traveled = 0.0; traveled < distance; traveled += dash + gap) {
      final segmentEnd = math.min(traveled + dash, distance);
      canvas.drawLine(
        start + direction * traveled,
        start + direction * segmentEnd,
        paint,
      );
    }
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset direction, Color color) {
    const length = 11.0;
    const spread = 0.55;
    final angle = math.atan2(direction.dy, direction.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - length * math.cos(angle - spread),
        tip.dy - length * math.sin(angle - spread),
      )
      ..lineTo(
        tip.dx - length * math.cos(angle + spread),
        tip.dy - length * math.sin(angle + spread),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawLabel(Canvas canvas, Offset center, String label, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 150);
    final rect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 12,
      height: textPainter.height + 7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      Paint()..color = Colors.white.withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke,
    );
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AlgorithmGraphPainter oldDelegate) => true;
}
