import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color seedColor = Color(0xFFFF5A1F);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    ).copyWith(primary: const Color(0xFFFF5A1F), onPrimary: Colors.white);

    return _theme(
      colorScheme,
      const AppThemeColors(
        background: Color(0xFFFFF8F3),
        surface: Color(0xFFFFFFFF),
        creamSurface: Color(0xFFFCEFE3),
        softAccentSurface: Color(0xFFFFE8DC),
        primaryText: Color(0xFF1A1612),
        secondaryText: Color(0xFF5A4F47),
        mutedText: Color(0xFF8C7E73),
        border: Color(0xFFEFE7DF),
        navbarBackground: Color(0xFF1A1612),
        inputFill: Color(0xFFFFFFFF),
        success: Color(0xFF2DBE60),
        warning: Color(0xFFFFB400),
        primaryGradientStart: Color(0xFFEF9F27),
        primaryGradientEnd: Color(0xFFD85A30),
        // cardShadow: 4% black, 12px blur — subtle card elevation
        cardShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        // buttonShadow: brand orange glow (32% alpha = 0x52)
        buttonShadow: [
          BoxShadow(
            color: Color(0x52FF5A1F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        // navbarShadow: 25% black, 40px blur — floating pill shadow
        navbarShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    ).copyWith(primary: const Color(0xFFFF5A1F), onPrimary: Colors.white);

    return _theme(
      colorScheme,
      const AppThemeColors(
        background: Color(0xFF1A1714),
        surface: Color(0xFF1C1917),
        creamSurface: Color(0xFF26211D),
        softAccentSurface: Color(0xFF33261E),
        primaryText: Color(0xFFFFF6EF),
        secondaryText: Color(0xFFD3C7BE),
        mutedText: Color(0xFFA89B91),
        border: Color(0xFF3B332E),
        navbarBackground: Color(0xFF1C1917),
        inputFill: Color(0xFF1C1917),
        success: Color(0xFF4ADE80),
        warning: Color(0xFFFBBF24),
        primaryGradientStart: Color(0xFFEF9F27),
        primaryGradientEnd: Color(0xFFD85A30),
        cardShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        // buttonShadow: slightly stronger glow in dark mode (40% alpha = 0x66)
        buttonShadow: [
          BoxShadow(
            color: Color(0x66FF5A1F),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
        navbarShadow: [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
    );
  }

  static ThemeData _theme(ColorScheme colorScheme, AppThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      extensions: [colors],
      textTheme: _textTheme(colors),
      appBarTheme: _appBarTheme(colors),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colors),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colors, colorScheme),
      checkboxTheme: _checkboxTheme(colorScheme),
      radioTheme: _radioTheme(colorScheme),
      switchTheme: _switchTheme(colorScheme),
      chipTheme: _chipTheme(colors),
      cardTheme: _cardTheme(colors),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colors, colorScheme),
      navigationBarTheme: _navigationBarTheme(colors, colorScheme),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
    );
  }

  static TextTheme _textTheme(AppThemeColors colors) {
    return TextTheme(
      displayLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      displayMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      displaySmall: GoogleFonts.bricolageGrotesque(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      headlineLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      headlineMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      headlineSmall: GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.primaryText,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.primaryText,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.primaryText,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.secondaryText,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.mutedText,
      ),
      // Used for badge text (e.g. "BESTSELLER", category tags)
      labelSmall: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: colors.mutedText,
      ),
    );
  }

  static AppBarTheme _appBarTheme(AppThemeColors colors) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colors.primaryText,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(AppThemeColors colors) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme cs) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: cs.primary),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    AppThemeColors colors,
    ColorScheme cs,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      hintStyle: TextStyle(color: colors.mutedText),
      labelStyle: TextStyle(color: colors.secondaryText),
    );
  }

  static CheckboxThemeData _checkboxTheme(ColorScheme cs) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? cs.primary
            : Colors.transparent;
      }),
    );
  }

  static RadioThemeData _radioTheme(ColorScheme cs) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? cs.primary : cs.outline;
      }),
    );
  }

  static SwitchThemeData _switchTheme(ColorScheme cs) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? cs.primary : cs.outline;
      }),
    );
  }

  static ChipThemeData _chipTheme(AppThemeColors colors) {
    return ChipThemeData(
      backgroundColor: colors.creamSurface,
      selectedColor: const Color(0xFFFFE8DC),
      side: BorderSide(color: colors.border),
      shape: const StadiumBorder(),
    );
  }

  static CardThemeData _cardTheme(AppThemeColors colors) {
    return CardThemeData(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.border),
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme(
    AppThemeColors colors,
    ColorScheme cs,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colors.navbarBackground,
      selectedItemColor: cs.primary,
      // Use onInverseSurface for muted text on dark navbar background
      unselectedItemColor: cs.onInverseSurface.withValues(alpha: 0.6),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    );
  }

  static NavigationBarThemeData _navigationBarTheme(
    AppThemeColors colors,
    ColorScheme cs,
  ) {
    return NavigationBarThemeData(
      backgroundColor: colors.navbarBackground,
      indicatorColor: cs.primary.withValues(alpha: 0.12),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme Extension — custom tokens not in Material 3's ColorScheme
// ---------------------------------------------------------------------------
//
// Usage in any widget:
//   final ac = Theme.of(context).extension<AppThemeColors>()!;
//   final ac = context.appColors;  // via ContextTheme extension (extensions.dart)
//
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // --- Surfaces ---
  final Color background;        // warm white page background
  final Color surface;           // card / input background
  final Color creamSurface;      // cream card background
  final Color softAccentSurface; // very light orange-tinted surface

  // --- Text ---
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;

  // --- Borders & Components ---
  final Color border;
  final Color navbarBackground;
  final Color inputFill;

  // --- Status ---
  final Color success;  // green — not in standard M3 scheme
  final Color warning;  // yellow — not in standard M3 scheme

  // --- Gradient stops (use AppGradients.primary for the LinearGradient) ---
  final Color primaryGradientStart;
  final Color primaryGradientEnd;

  // --- Shadows ---
  final List<BoxShadow> cardShadow;    // subtle card elevation
  final List<BoxShadow> buttonShadow;  // orange glow for primary buttons
  final List<BoxShadow> navbarShadow;  // floating pill navbar shadow

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.creamSurface,
    required this.softAccentSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.border,
    required this.navbarBackground,
    required this.inputFill,
    required this.success,
    required this.warning,
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    required this.cardShadow,
    required this.buttonShadow,
    required this.navbarShadow,
  });

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? creamSurface,
    Color? softAccentSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? border,
    Color? navbarBackground,
    Color? inputFill,
    Color? success,
    Color? warning,
    Color? primaryGradientStart,
    Color? primaryGradientEnd,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? buttonShadow,
    List<BoxShadow>? navbarShadow,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      creamSurface: creamSurface ?? this.creamSurface,
      softAccentSurface: softAccentSurface ?? this.softAccentSurface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      navbarBackground: navbarBackground ?? this.navbarBackground,
      inputFill: inputFill ?? this.inputFill,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      primaryGradientStart: primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      cardShadow: cardShadow ?? this.cardShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      navbarShadow: navbarShadow ?? this.navbarShadow,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      creamSurface: Color.lerp(creamSurface, other.creamSurface, t)!,
      softAccentSurface: Color.lerp(softAccentSurface, other.softAccentSurface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      border: Color.lerp(border, other.border, t)!,
      navbarBackground: Color.lerp(navbarBackground, other.navbarBackground, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      primaryGradientStart: Color.lerp(primaryGradientStart, other.primaryGradientStart, t)!,
      primaryGradientEnd: Color.lerp(primaryGradientEnd, other.primaryGradientEnd, t)!,
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      buttonShadow: BoxShadow.lerpList(buttonShadow, other.buttonShadow, t)!,
      navbarShadow: BoxShadow.lerpList(navbarShadow, other.navbarShadow, t)!,
    );
  }
}
