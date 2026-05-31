import 'package:flutter/material.dart';

/// Reúne medidas, espaçamentos e tamanhos reutilizados no app.
class AppStyles {
  const AppStyles._();

  static const double tabletBreakpoint = 720;
  static const double desktopBreakpoint = 1024;

  static const double contentMaxWidth = 420;
  static const double contentMaxWidthMedium = 720;
  static const double contentMaxWidthWide = 840;
  static const double formMaxWidthWide = 480;
  static const double listMaxWidthMedium = 840;
  static const double listMaxWidthWide = 1120;
  static const double splitLayoutBreakpoint = 760;
  static const double actionWrapBreakpoint = 560;
  static const double inputRadius = 16;
  static const double buttonRadius = 16;
  static const double focusedBorderWidth = 1.5;
  static const double busyIndicatorSize = 20;
  static const double busyIndicatorStrokeWidth = 2;
  static const double itemSpacing = 16;
  static const double actionSpacing = 12;

  static const double pagePaddingCompact = 16;
  static const double pagePaddingRegular = 24;
  static const double pagePaddingWide = 32;

  static const Size buttonMinimumSize = Size.fromHeight(48);
  static const Size dialogActionMinimumSize = Size(0, 48);

  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const EdgeInsets sectionPadding = EdgeInsets.all(16);
  static const EdgeInsets listPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );
  static const EdgeInsets compactPadding = EdgeInsets.all(12);
  static const EdgeInsets topPadding8 = EdgeInsets.only(top: 8);
  static const EdgeInsets bottomPadding16 = EdgeInsets.only(bottom: 16);
  static const EdgeInsets horizontalPadding16 = EdgeInsets.symmetric(
    horizontal: 16,
  );

  static const SizedBox gap4 = SizedBox(height: 4);
  static const SizedBox gap8 = SizedBox(height: 8);
  static const SizedBox gap12 = SizedBox(height: 12);
  static const SizedBox gap16 = SizedBox(height: 16);
  static const SizedBox gap20 = SizedBox(height: 20);
  static const SizedBox gap24 = SizedBox(height: 24);
  static const SizedBox gap32 = SizedBox(height: 32);
  static const SizedBox gap64 = SizedBox(height: 64);
  static const SizedBox gapWidth12 = SizedBox(width: 12);

  static const double iconSmall = 18;
  static const double iconMedium = 20;
  static const double cardRadius = 12;
  static const double headerSize = 28;
  static const double titleSize = 20;
  static const double subtitleSize = 16;

  static const Duration feedbackDelay = Duration(milliseconds: 350);
}
