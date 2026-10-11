import 'package:flutter/material.dart';

/// Selects a child from the same breakpoints as the legacy OMS widget.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.largeScreen,
    required this.mediumScreen,
    required this.smallScreen,
  });

  final Widget largeScreen;
  final Widget mediumScreen;
  final Widget smallScreen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 1200) return largeScreen;
      if (constraints.maxWidth > 600) return mediumScreen;
      return smallScreen;
    },
  );
}
