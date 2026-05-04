import 'package:flutter/material.dart';

class FeatureChip extends StatelessWidget {
  const FeatureChip({
    required this.label,
    required this.value,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final String value;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? const Color(0xFFF1F5F9);
    final fg = foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return content;
    }
    return Tooltip(message: tooltip!, child: content);
  }
}
