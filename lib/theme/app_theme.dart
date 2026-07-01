import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores centrais do app. Evita hex espalhado pelas telas e garante
/// consistência visual em todo o fluxo.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF303841); // fundo principal
  static const surface = Color(0xFF3A4750); // cards / superfícies elevadas
  static const surfaceHigh = Color(0xFF4D5C68); // inputs / superfícies destacadas
  static const accent = Color(0xFF1FAE6B); // verde-esmeralda de marca (StockHub)
  static const accentSecondary = Color(0xFF6FCB9F); // verde-esmeralda claro, detalhes/realces
  static const textLight = Color(0xFFF3F1EC);
  static const textMuted = Color(0xFF9BA3AE);
  static const danger = Color(0xFFE05353); // só para exclusão/erro, não é cor de marca
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  AppRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 18.0;
}

/// Estilos de texto reutilizáveis. `display`/`heading` usam uma fonte com
/// mais personalidade; `body`/`bodyMuted` priorizam legibilidade.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        height: 1.15,
      );

  static TextStyle get heading => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );

  static TextStyle get subheading => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textLight,
      );

  static TextStyle get bodyMuted => GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textMuted,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.textLight,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.accent),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceHigh,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.surfaceHigh,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
