import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 40,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: widget.onAction,
                    child: Text(widget.actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
