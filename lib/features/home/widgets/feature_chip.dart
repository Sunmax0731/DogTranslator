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
    final colorScheme = Theme.of(context).colorScheme;
    final bg =
        backgroundColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final fg = foregroundColor ?? colorScheme.onSurface;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
    return Tooltip(
      message: tooltip!,
      waitDuration: const Duration(milliseconds: 250),
      showDuration: const Duration(seconds: 4),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: content),
    );
  }
}
