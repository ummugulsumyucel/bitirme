import 'package:flutter/material.dart';

/// UniConnect marka renkleri ve uygulama geneli tema.
abstract final class UniBrand {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color accent = Color(0xFF5A7FCF);
  static const Color accentLight = Color(0xFF93B4F4);
}

ThemeData uniTheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: UniBrand.primary,
    brightness: brightness,
    primary: UniBrand.primary,
    secondary: UniBrand.accent,
  );

  final scheme = base.copyWith(
    // Açık tema - eski renkler korundu
    surfaceContainerLowest: brightness == Brightness.light
        ? const Color(0xFFF0F4FC)
        : const Color(0xFF2A3142), // Koyu tema - orta gri-mavi
    surfaceContainerLow: brightness == Brightness.light
        ? const Color(0xFFE8EEF8)
        : const Color(0xFF323B52), // Kartlar - arka plandan biraz açık
    surfaceContainer: brightness == Brightness.light
        ? const Color(0xFFE2EAF5)
        : const Color(0xFF3A4460), // Container - daha belirgin
    surface: brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF1E2538), // Ana arka plan - koyu gri-mavi (siyah değil)
    // Koyu temada metin kontrastını artır
    onSurface: brightness == Brightness.light
        ? Colors.black87
        : const Color(0xFFECEFF8), // Koyu temada neredeyse beyaz
    onSurfaceVariant: brightness == Brightness.light
        ? Colors.black54
        : const Color(0xFFB8C2D8), // Koyu temada açık gri-mavi
  );

  final titleStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    color: Colors.white, // Her iki temada da beyaz
    fontSize: 20,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      backgroundColor: brightness == Brightness.light
          ? scheme.primary
          : const Color(0xFF263354),
      foregroundColor: Colors.white, // Her iki temada da beyaz
      surfaceTintColor: Colors.transparent,
      titleTextStyle: titleStyle,
      iconTheme: const IconThemeData(color: Colors.white), // Her iki temada da beyaz
    ),
    cardTheme: CardThemeData(
      elevation: brightness == Brightness.light ? 0 : 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: brightness == Brightness.light
          ? scheme.surfaceContainerLow
          : const Color(0xFF323B52), // Koyu temada kartlar belirgin
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: brightness == Brightness.light
          ? scheme.surface
          : const Color(0xFF232C42), // Koyu temada drawer yumuşak
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      selectedColor: scheme.primary,
      selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Koyu temada metin rengini belirgin yap
      textColor: scheme.onSurface,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? scheme.surface
          : const Color(0xFF263050), // Koyu temada nav bar yumuşak mavi-gri
      indicatorColor: scheme.primaryContainer.withValues(alpha: 0.6),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: UniBrand.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: UniBrand.accent,
        foregroundColor: Colors.white,
        elevation: brightness == Brightness.light ? 0 : 4, // Koyu temada daha belirgin
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(
          color: brightness == Brightness.light 
            ? scheme.primary.withValues(alpha: 0.5)
            : scheme.primary.withValues(alpha: 0.8), // Koyu temada daha belirgin border
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: brightness == Brightness.light 
            ? scheme.outlineVariant
            : scheme.outlineVariant.withValues(alpha: 0.8), // Koyu temada daha belirgin
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      // Koyu temada metin rengini belirgin yap
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: brightness == Brightness.light 
        ? const Color(0xFF1E3A8A)
        : const Color(0xFF3B4252),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(
        alpha: brightness == Brightness.light ? 0.6 : 0.4
      ),
      space: 1,
    ),
    // Koyu temada text theme'i güçlendir
    textTheme: brightness == Brightness.light 
      ? null 
      : TextTheme(
          bodyLarge: TextStyle(color: scheme.onSurface),
          bodyMedium: TextStyle(color: scheme.onSurface),
          bodySmall: TextStyle(color: scheme.onSurfaceVariant),
          titleLarge: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500),
        ),
  );
}
