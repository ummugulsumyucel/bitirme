import 'package:flutter/material.dart';

/// Responsive tasarım ve overflow önleme yardımcı fonksiyonları
class ResponsiveUtils {
  /// Ekran genişliğine göre padding değeri döndürür
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    if (width < 900) return 24.0;
    return 32.0;
  }

  /// Ekran genişliğine göre font boyutu döndürür
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return baseFontSize * 0.9;
    if (width < 600) return baseFontSize;
    return baseFontSize * 1.1;
  }

  /// Ekran yüksekliğine göre vertical spacing döndürür
  static double getVerticalSpacing(BuildContext context, double baseSpacing) {
    final height = MediaQuery.of(context).size.height;
    if (height < 600) return baseSpacing * 0.7;
    if (height < 800) return baseSpacing;
    return baseSpacing * 1.2;
  }

  /// Küçük ekranlar için mi kontrol eder
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Tablet veya daha büyük ekran mı kontrol eder
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Güvenli metin uzunluğu döndürür (overflow önlemek için)
  static String getSafeText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Row içinde güvenli Text widget'ı oluşturur
  static Widget buildSafeRowText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Expanded(
      child: Text(text, style: style, maxLines: maxLines, overflow: overflow),
    );
  }

  /// Flexible Text widget'ı oluşturur
  static Widget buildFlexibleText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
    int flex = 1,
  }) {
    return Flexible(
      flex: flex,
      child: Text(text, style: style, maxLines: maxLines, overflow: overflow),
    );
  }
}

/// Overflow korumalı Container widget'ı
class SafeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;

  const SafeContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}

/// Overflow korumalı Row widget'ı
class SafeRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}

/// Overflow korumalı Column widget'ı
class SafeColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SafeColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}
