import 'dart:ui';

import 'package:flutter/material.dart';

import '../shared/widgets/algorithm_card_grid.dart';

import 'grafo_screen.dart' as grafo;
import 'asignacion_screen.dart' as asignacion;
import 'johnson_screen.dart';
import 'esquina_nor_oeste_screen.dart';
import 'sorting_methods_screen.dart';

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({super.key});

  @override
  State<MenuPrincipalScreen> createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bgAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Centro de Módulos Algorítmicos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _bgAnimationController,
        builder: (context, child) {
          final animVal = _bgAnimationController.value;
          return Stack(
            children: [
              // Puntos de luz pequeños y dinámicos
              Positioned(
                top: 10 + (animVal * 110),
                left: -10 + (animVal * 90),
                child: _buildBlurCircle(
                  color: const Color(0xFFEC4899),
                  size: 160,
                  blur: 50,
                  opacity: 0.3,
                ),
              ),
              Positioned(
                top: 180 - (animVal * 90),
                right: 0 + (animVal * 100),
                child: _buildBlurCircle(
                  color: const Color(0xFF6366F1),
                  size: 170,
                  blur: 55,
                  opacity: 0.35,
                ),
              ),
              Positioned(
                bottom: 20 + (animVal * 80),
                left: 40 - (animVal * 70),
                child: _buildBlurCircle(
                  color: const Color(0xFFF59E0B),
                  size: 140,
                  blur: 45,
                  opacity: 0.25,
                ),
              ),
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.transparent),
              ),
              // Contenido principal
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeController.drive(
                      Tween<double>(begin: 0.0, end: 1.0),
                    ),
                    child: SlideTransition(
                      position: _slideController.drive(
                        Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selecciona un Algoritmo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Elige un módulo interactivo para simular y resolver problemas de optimización',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          AlgorithmCardGrid(
                            children: [
                              _TarjetaModuloMejorada(
                                titulo: 'Redes y Grafos',
                                descripcion: 'Crea nodos y conexiones, consulta la matriz de adyacencia y analiza los grados de tu grafo.',
                                icono: Icons.alt_route_rounded,
                                colorAcento: const Color(0xFFEC4899),
                                badgeText: 'Disponible',
                                delay: 0,
                                ilustracionWidget: _buildGraphIllustration(
                                  const Color(0xFFEC4899),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const grafo.GrafoScreen(),
                                    ),
                                  );
                                },
                              ),
                              _TarjetaModuloMejorada(
                                titulo: 'Método de Asignación',
                                descripcion: 'Asigna recursos a tareas y compara soluciones de costo mínimo o máximo.',
                                icono: Icons.assignment_turned_in_rounded,
                                colorAcento: const Color(0xFF6366F1),
                                badgeText: 'Disponible',
                                delay: 100,
                                ilustracionWidget: _buildAssignmentIllustration(
                                  const Color(0xFF6366F1),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const asignacion.AsignacionScreen(),
                                    ),
                                  );
                                },
                              ),
                              _TarjetaModuloMejorada(
                                titulo: 'Algoritmo de Johnson',
                                descripcion: 'Modela una red de actividades y consulta tiempos tempranos, tiempos tardíos, holguras y ruta crítica.',
                                icono: Icons.schedule_rounded,
                                colorAcento: const Color(0xFFF59E0B),
                                badgeText: 'Disponible',
                                delay: 200,
                                ilustracionWidget: _buildScheduleIllustration(
                                  const Color(0xFFF59E0B),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const JohnsonScreen(),
                                    ),
                                  );
                                },
                              ),
                              _TarjetaModuloMejorada(
                                titulo: 'Esquina Noroeste',
                                descripcion: 'Define orígenes, destinos, ofertas y demandas para explorar la distribución de recursos y sus costos.',
                                icono: Icons.grid_on_rounded,
                                colorAcento: const Color(0xFF10B981),
                                badgeText: 'Disponible',
                                delay: 300,
                                ilustracionWidget: _buildTransportIllustration(
                                  const Color(0xFF10B981),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EsquinaNorOesteScreen(),
                                    ),
                                  );
                                },
                              ),
                              _TarjetaModuloMejorada(
                                titulo: 'Métodos de Ordenamiento',
                                descripcion: 'Visualiza Selection, Insertion, Merge y Shell Sort paso a paso mediante simulación interactiva de elementos.',
                                icono: Icons.sort_rounded,
                                colorAcento: const Color(0xFF06B6D4),
                                badgeText: 'Nuevo',
                                delay: 400,
                                ilustracionWidget: _buildSortingIllustration(
                                  const Color(0xFF06B6D4),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SortingMethodsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildInfoTip(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlurCircle({
    required Color color,
    required double size,
    required double blur,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }

  Widget _buildGraphIllustration(Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              left: 35,
              bottom: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: 35,
              bottom: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            CustomPaint(
              size: const Size(100, 100),
              painter: LinePainter(color),
            ),
            Icon(Icons.hub_outlined, color: color, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentIllustration(Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 15,
              top: 15,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 15,
              top: 40,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 15,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              right: 15,
              top: 15,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              right: 15,
              top: 40,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Icon(Icons.table_chart_rounded, color: color, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleIllustration(Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 15,
              top: 20,
              child: Container(
                width: 30,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 15,
              top: 35,
              child: Container(
                width: 45,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 20,
              child: Container(
                width: 35,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Icon(Icons.linear_scale_rounded, color: color, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportIllustration(Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(child: Icon(Icons.grid_on_rounded, color: color, size: 36)),
    );
  }

  Widget _buildSortingIllustration(Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 25,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 65,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 35,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF818CF8).withValues(alpha: 0.08),
            const Color(0xFF6366F1).withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF818CF8),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo: Explora los nuevos algoritmos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Simula métodos de ordenamiento visualmente',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaModuloMejorada extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color colorAcento;
  final String badgeText;
  final Widget ilustracionWidget;
  final VoidCallback onTap;
  final int delay;

  const _TarjetaModuloMejorada({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colorAcento,
    required this.badgeText,
    required this.ilustracionWidget,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_TarjetaModuloMejorada> createState() => _TarjetaModuloMejoradaState();
}

class _TarjetaModuloMejoradaState extends State<_TarjetaModuloMejorada>
    with TickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _hoverController;
  late AnimationController _enterController;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _enterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _enterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterController.drive(Tween<double>(begin: 0.0, end: 1.0)),
      child: SlideTransition(
        position: _enterController.drive(
          Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() => isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => isHovered = false);
            _hoverController.reverse();
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onTap,
              child: AnimatedBuilder(
                animation: _hoverController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -8 * _hoverController.value),
                    child: Ink(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? const Color(0xFF18181B).withValues(alpha: 0.9)
                            : const Color(0xFF121214).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isHovered
                              ? widget.colorAcento.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.08),
                          width: isHovered ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          if (isHovered)
                            BoxShadow(
                              color: widget.colorAcento.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: widget.colorAcento.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: widget.colorAcento.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      widget.icono,
                                      color: widget.colorAcento,
                                      size: 22,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.colorAcento.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: widget.colorAcento.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      widget.badgeText,
                                      style: TextStyle(
                                        color: widget.colorAcento,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              widget.ilustracionWidget,
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.titulo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.descripcion,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    'Explorar',
                                    style: TextStyle(
                                      color: widget.colorAcento,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Transform.translate(
                                    offset: Offset(
                                      4 * _hoverController.value,
                                      0,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: widget.colorAcento,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Color color;

  LinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(20, 20), const Offset(80, 20), paint);
    canvas.drawLine(const Offset(20, 20), const Offset(35, 80), paint);
    canvas.drawLine(const Offset(80, 20), const Offset(65, 80), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
