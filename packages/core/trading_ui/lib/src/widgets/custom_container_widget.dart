import 'package:flutter/material.dart';

/// Reusable surface container with the existing OMS defaults.
class CustomContainerWidget extends StatelessWidget {
  const CustomContainerWidget({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    this.margin,
    this.borderRadius = 8,
    this.backgroundColor,
    this.shadowColor,
    this.spreadRadius = 1,
    this.blurRadius = 6,
    this.offset = const Offset(0, 2),
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double spreadRadius;
  final double blurRadius;
  final Offset offset;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          boxShadow: [
            BoxShadow(
              color:
                  shadowColor ?? Colors.black.withAlpha((0.08 * 255).toInt()),
              spreadRadius: spreadRadius,
              blurRadius: blurRadius,
              offset: offset,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
