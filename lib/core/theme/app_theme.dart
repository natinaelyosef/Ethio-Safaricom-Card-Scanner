import 'package:flutter/material.dart';

/// Ethio & Safaricom Card Scanner palette.
///
/// Emerald remains the brand anchor, while a handful of bright arcade
/// accents and chunky outlines give the interface its playful, game-like
/// character. Dark values keep the same identity with stronger contrast.
class AppColors {
  AppColors._();

  // ---- Light palette (brand) ----
  static const Color backgroundLight = Color(0xFFF5F9F6);
  static const Color primaryLight = Color(0xFF008F4C);
  static const Color primaryDarkGreen = Color(0xFF006B3C);
  static const Color lightGreen = Color(0xFFE7F6ED);
  static const Color textPrimaryLight = Color(0xFF192720);
  static const Color textSecondaryLight = Color(0xFF68776E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFD4E5D9);
  static const Color errorLight = Color(0xFFD32F2F);

  // ---- Dark palette (derived) ----
  static const Color backgroundDark = Color(0xFF0E1511);
  static const Color cardDark = Color(0xFF182119);
  static const Color primaryDark = Color(0xFF4CC38A);
  static const Color darkGreenSurface = Color(0xFF112419);
  static const Color textPrimaryDark = Color(0xFFEAF3ED);
  static const Color textSecondaryDark = Color(0xFF9AA8A0);
  static const Color borderDark = Color(0xFF26332C);
  static const Color errorDark = Color(0xFFFFB4AB);

  /// Shared semantic accents used by banners and result cards.
  static const Color successLight = Color(0xFF006B3C);
  static const Color warningLight = Color(0xFF7A5A00);
  static const Color errorAccentLight = Color(0xFFB3261E);

  /// Bright scanning accent used on the camera overlay in both themes.
  static const Color scanAccent = Color(0xFF7BE3AE);

  // ---- Playful arcade accents ----
  static const Color gameInkLight = Color(0xFF163A29);
  static const Color gameInkDark = Color(0xFFEAF3ED);
  static const Color gameYellow = Color(0xFFFFD166);
  static const Color gameCoral = Color(0xFFFF7A7A);
  static const Color gameBlue = Color(0xFF6EC6FF);
  static const Color gamePurple = Color(0xFFB49BFF);
  static const Color gameOrange = Color(0xFFFFA45B);

  static const Color backdropTopLight = Color(0xFFF4FCF7);
  static const Color backdropBottomLight = Color(0xFFE7F3FF);
  static const Color backdropTopDark = Color(0xFF0B130E);
  static const Color backdropBottomDark = Color(0xFF101B22);
}

/// Chunky, offset elevation that makes cards and controls feel like board
/// game pieces instead of flat Material surfaces.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> light = [
    BoxShadow(color: Color(0x2B123B28), blurRadius: 0, offset: Offset(3, 4)),
    BoxShadow(color: Color(0x12123B28), blurRadius: 16, offset: Offset(0, 7)),
  ];

  static const List<BoxShadow> dark = [
    BoxShadow(color: Color(0x99000000), blurRadius: 0, offset: Offset(3, 4)),
    BoxShadow(color: Color(0x55000000), blurRadius: 16, offset: Offset(0, 7)),
  ];

  /// Card shadow matching the current brightness.
  static List<BoxShadow> of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? light : dark;
}

/// Builds the Material 3 light and dark themes for the whole app.
class AppTheme {
  AppTheme._();

  static const seedColor = AppColors.primaryLight;

  /// Corner radius shared by every card, sheet and dialog.
  static const double radius = 22;

  static ThemeData get light => _theme(
    brightness: Brightness.light,
    background: AppColors.backgroundLight,
    card: AppColors.cardLight,
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: AppColors.lightGreen,
    onPrimaryContainer: AppColors.primaryDarkGreen,
    secondary: AppColors.primaryDarkGreen,
    onBackground: AppColors.textPrimaryLight,
    onSurface: AppColors.textPrimaryLight,
    secondaryText: AppColors.textSecondaryLight,
    border: AppColors.borderLight,
    error: AppColors.errorLight,
    onError: Colors.white,
  );

  static ThemeData get dark => _theme(
    brightness: Brightness.dark,
    background: AppColors.backgroundDark,
    card: AppColors.cardDark,
    primary: AppColors.primaryDark,
    onPrimary: const Color(0xFF062315),
    primaryContainer: AppColors.darkGreenSurface,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryDark,
    onBackground: AppColors.textPrimaryDark,
    onSurface: AppColors.textPrimaryDark,
    secondaryText: AppColors.textSecondaryDark,
    border: AppColors.borderDark,
    error: AppColors.errorDark,
    onError: const Color(0xFF3B0A05),
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onBackground,
    required Color onSurface,
    required Color secondaryText,
    required Color border,
    required Color error,
    required Color onError,
  }) {
    final light = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: light ? Colors.white : const Color(0xFF062315),
      secondaryContainer: primaryContainer,
      onSecondaryContainer: onPrimaryContainer,
      error: error,
      onError: onError,
      surface: card,
      onSurface: onSurface,
      onSurfaceVariant: secondaryText,
      outline: border,
      outlineVariant: border,
      shadow: light ? const Color(0xFF0A2E1E) : Colors.black,
      surfaceContainerHighest: light
          ? const Color(0xFFEDF3EF)
          : const Color(0xFF212B24),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
    );

    final bodyMedium = base.textTheme.bodyMedium?.copyWith(
      color: onBackground,
      height: 1.4,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
      textTheme: base.textTheme
          .apply(bodyColor: onBackground, displayColor: onBackground)
          .copyWith(
            bodyMedium: bodyMedium,
            titleLarge: base.textTheme.titleLarge?.copyWith(
              color: onBackground,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              color: onBackground,
              fontWeight: FontWeight.w700,
            ),
            titleSmall: base.textTheme.titleSmall?.copyWith(
              color: onBackground,
              fontWeight: FontWeight.w700,
            ),
            labelLarge: base.textTheme.labelLarge?.copyWith(
              color: onBackground,
              fontWeight: FontWeight.w600,
            ),
            labelMedium: base.textTheme.labelMedium?.copyWith(
              color: secondaryText,
              fontWeight: FontWeight.w600,
            ),
            labelSmall: base.textTheme.labelSmall?.copyWith(
              color: secondaryText,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        backgroundColor: light
            ? AppColors.primaryDarkGreen
            : const Color(0xFF1E3A2A),
        contentTextStyle: TextStyle(
          color: light ? Colors.white : AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: light ? AppColors.primaryDarkGreen : border,
              width: 1.4,
            ),
          ),
          textStyle: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: light ? AppColors.primaryDarkGreen : secondary,
          minimumSize: const Size(64, 52),
          side: BorderSide(
            color: light
                ? AppColors.gameInkLight.withValues(alpha: 0.24)
                : border,
            width: 1.6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: light ? AppColors.primaryDarkGreen : secondary,
          textStyle: base.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: light
              ? AppColors.gameYellow
              : AppColors.darkGreenSurface,
          selectedForegroundColor: light
              ? AppColors.gameInkLight
              : onPrimaryContainer,
          foregroundColor: secondaryText,
          side: BorderSide(
            color: light
                ? AppColors.gameInkLight.withValues(alpha: 0.2)
                : border,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: secondaryText, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: light ? border : AppColors.borderDark,
            width: 1.4,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: light ? border : AppColors.borderDark,
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: primary, width: 2.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius + 4),
        ),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: base.textTheme.bodySmall?.copyWith(
          color: secondaryText,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : (light ? AppColors.borderLight : AppColors.borderDark),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : border,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? onPrimary
              : (light ? AppColors.cardLight : AppColors.textSecondaryDark),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : secondaryText,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        strokeWidth: 2.5,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: base.textTheme.bodyMedium?.copyWith(color: onSurface),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: base.textTheme.bodyMedium?.copyWith(color: onSurface),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: light ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: base.textTheme.labelSmall?.copyWith(
          color: light ? Colors.white : AppColors.backgroundDark,
        ),
      ),
    );
  }
}
