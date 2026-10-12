import 'package:app_grafos/features/sorting/domain/sorting_algorithm.dart';
import 'package:app_grafos/features/sorting/domain/sorting_order.dart';
import 'package:app_grafos/features/sorting/domain/sorting_validator.dart';
import 'package:app_grafos/features/sorting/presentation/providers/sorting_visualization_provider.dart';
import 'package:app_grafos/features/sorting/presentation/widgets/sorting_visualization_widget.dart';
import 'package:app_grafos/features/sorting/presentation/widgets/sorting_help_menu.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import '../app/app_theme.dart';
import '../shared/widgets/algorithm_scaffold.dart';

/// Main screen for sorting visualization
class SortingVisualizationScreen extends StatefulWidget {
  final SortingAlgorithm algorithm;
  final List<int> initialArray;
  final SortingOrder initialOrder;

  const SortingVisualizationScreen({
    super.key,
    required this.algorithm,
    required this.initialArray,
    this.initialOrder = SortingOrder.ascending,
  });

  @override
  State<SortingVisualizationScreen> createState() =>
      _SortingVisualizationScreenState();
}

class _SortingVisualizationScreenState
    extends State<SortingVisualizationScreen> {
  late SortingVisualizationProvider _provider;
  Timer? _animationTimer;
  double? _animationSpeed;

  @override
  void initState() {
    super.initState();
    _provider = _createProvider(widget.initialArray, widget.initialOrder);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _provider.dispose();
    super.dispose();
  }

  void _showInputDialog() {
    _provider.pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InputDialog(
        onRandomArray: (size) {
          final array = SortingValidator.generateRandomArray(size);
          Navigator.pop(context); // Cierra diálogo
          _resetWithNewArray(array);
        },
        onManualArray: (array) {
          Navigator.pop(context); // Cierra diálogo
          _resetWithNewArray(array);
        },
      ),
    );
  }

  void _resetWithNewArray(List<int> array) {
    setState(() {
      _stopAnimation();
      final order = _provider.order;
      final speed = _provider.speed;
      _provider.dispose();
      _provider = _createProvider(array, order)..setSpeed(speed);
    });
  }

  SortingVisualizationProvider _createProvider(
    List<int> array,
    SortingOrder order,
  ) {
    return SortingVisualizationProvider(
      array: array,
      algorithm: widget.algorithm,
      order: order,
    )..addListener(_syncAnimation);
  }

  void _syncAnimation() {
    if (!_provider.isPlaying || _provider.isComplete) {
      _stopAnimation();
      return;
    }
    if (_animationSpeed != _provider.speed) _stopAnimation();
    _startAnimation();
  }

  void _startAnimation() {
    if (_animationTimer != null) return;

    _animationSpeed = _provider.speed;
    final delayMs = (500 / _provider.speed).toInt();
    _animationTimer = Timer.periodic(Duration(milliseconds: delayMs), (_) {
      _provider.advanceStep();
    });
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _animationSpeed = null;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) _stopAnimation();
          },
          child: AlgorithmScaffold(
            accent: AppColors.sorting,
            title: widget.algorithm.displayName,
            icon: Icons.sort_rounded,
            actions: [SortingHelpMenu(onOpen: _provider.pause)],
            body: SortingVisualizationWidget(
              provider: _provider,
              onNewSort: _showInputDialog,
            ),
          ),
        );
      },
    );
  }
}

/// Input dialog for array selection
class _InputDialog extends StatefulWidget {
  final Function(int) onRandomArray;
  final Function(List<int>) onManualArray;

  const _InputDialog({
    required this.onRandomArray,
    required this.onManualArray,
  });

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  late TextEditingController _manualController;
  int _randomSize = 10;
  String? _manualError;

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController();
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _submitManualInput() {
    final (numbers, error) = SortingValidator.parseInputString(
      _manualController.text,
    );
    if (error != null) {
      setState(() => _manualError = error);
      return;
    }
    widget.onManualArray(numbers);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ingresa los números para ordenar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Números deben estar entre 1 y 100, máximo 20 elementos',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Random array option
            const Text(
              'Opción 1: Números aleatorios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _randomSize.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '$_randomSize',
                    onChanged: (value) {
                      setState(() => _randomSize = value.toInt());
                    },
                  ),
                ),
                Text('$_randomSize'),
              ],
            ),
            ElevatedButton(
              onPressed: () => widget.onRandomArray(_randomSize),
              child: const Text('Generar aleatorios'),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Manual input option
            const Text(
              'Opción 2: Ingresar manualmente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _manualController,
              onSubmitted: (_) => _submitManualInput(),
              onChanged: (_) {
                if (_manualError != null) setState(() => _manualError = null);
              },
              decoration: InputDecoration(
                labelText: 'Números a ordenar',
                hintText: 'Ej: 5,3,8,1,9',
                helperText: 'Números separados por comas',
                errorText: _manualError,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitManualInput,
              child: const Text('Usar estos números'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
