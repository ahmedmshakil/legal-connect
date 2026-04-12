import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? (color ?? Theme.of(context).cardColor) : null,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
