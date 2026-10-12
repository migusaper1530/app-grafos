import 'package:flutter/material.dart';

/// Colores del laboratorio, compartidos por el menú y sus módulos.
abstract final class AppColors {
  static const primary = Color(0xFF818CF8);
  static const primarySoft = Color(0xFF202039);
  static const background = Color(0xFF09090B);
  static const surface = Color(0xFF121214);
  static const surfaceMuted = Color(0xFF1E1E24);
  static const border = Color(0xFF34343F);
  static const text = Color(0xFFF4F4F5);
  static const textSecondary = Color(0xFFD4D4D8);
  static const textMuted = Color(0xFFA1A1AA);
  static const success = Color(0xFF34D399);
  static const successSoft = Color(0xFF122B24);
  static const successText = Color(0xFF6EE7B7);
  static const warningSoft = Color(0xFF302614);
  static const warningText = Color(0xFFFCD34D);
  static const comparing = Color(0xFFFBBF24);
  static const moving = Color(0xFFFB923C);
  static const unsorted = Color(0xFF94A3B8);
  static const graph = Color(0xFFF472B6);
  static const johnson = Color(0xFFFBBF24);
  static const sorting = Color(0xFF22D3EE);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.background,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          onSurfaceVariant: AppColors.textMuted,
          outline: AppColors.border,
          outlineVariant: AppColors.border,
          error: const Color(0xFFFDA4AF),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: const Size(0, 44),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          shape: shape,
          minimumSize: const Size(0, 44),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.surfaceMuted,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceMuted,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.primarySoft),
        dividerThickness: 1,
        headingTextStyle: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
