import 'package:flutter/material.dart';

import 'app_styles.dart';

/// Define presets de largura para não espalhar números mágicos nas telas.
enum AppLayoutWidth { form, content, list }

/// Aplica padding e largura máxima de forma responsiva ao conteúdo da tela.
class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    required this.child,
    this.width = AppLayoutWidth.content,
    this.scrollable = false,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final AppLayoutWidth width;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  /// Retorna true quando a janela está em largura compacta.
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppStyles.tabletBreakpoint;
  }

  /// Informa se a largura atual corresponde a uma tela ampla.
  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppStyles.desktopBreakpoint;
  }

  /// Calcula o padding padrão de página com base na largura disponível.
  static EdgeInsets pagePadding(BuildContext context) {
    return pagePaddingForWidth(MediaQuery.sizeOf(context).width);
  }

  /// Calcula o padding externo ideal para a largura informada.
  static EdgeInsets pagePaddingForWidth(double width) {
    final horizontal = width >= AppStyles.desktopBreakpoint
        ? AppStyles.pagePaddingWide
        : width >= AppStyles.tabletBreakpoint
        ? AppStyles.pagePaddingRegular
        : AppStyles.pagePaddingCompact;

    final vertical = width >= AppStyles.tabletBreakpoint
        ? AppStyles.pagePaddingRegular
        : AppStyles.pagePaddingCompact;

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Resolve a largura máxima de conteúdo para cada preset.
  static double maxWidthFor(double width, AppLayoutWidth preset) {
    switch (preset) {
      case AppLayoutWidth.form:
        return width >= AppStyles.desktopBreakpoint
            ? AppStyles.formMaxWidthWide
            : AppStyles.contentMaxWidth;
      case AppLayoutWidth.content:
        return width >= AppStyles.desktopBreakpoint
            ? AppStyles.contentMaxWidthWide
            : width >= AppStyles.tabletBreakpoint
            ? AppStyles.contentMaxWidthMedium
            : AppStyles.contentMaxWidth;
      case AppLayoutWidth.list:
        return width >= AppStyles.desktopBreakpoint
            ? AppStyles.listMaxWidthWide
            : width >= AppStyles.tabletBreakpoint
            ? AppStyles.listMaxWidthMedium
            : AppStyles.contentMaxWidth;
    }
  }

  /// Define 1 ou 2 colunas para os cards de evento conforme a largura.
  static int eventColumnsForWidth(double width) {
    if (width >= AppStyles.splitLayoutBreakpoint) {
      return 2;
    }

    return 1;
  }

  @override
  /// Monta o contêiner responsivo que envolve o conteúdo da tela.
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final resolvedPadding = padding ?? pagePaddingForWidth(viewportWidth);
        final resolvedMaxWidth = maxWidthFor(viewportWidth, width);
        final constrainedChild = Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
            child: child,
          ),
        );

        // Quando precisa rolar, o mesmo conteúdo é embrulhado em scroll.
        if (scrollable) {
          return SingleChildScrollView(
            padding: resolvedPadding,
            child: constrainedChild,
          );
        }

        return Padding(padding: resolvedPadding, child: constrainedChild);
      },
    );
  }
}
