import 'package:flutter/material.dart';

class FeatureChip extends StatelessWidget {
  const FeatureChip({
    required this.label,
    required this.value,
    this.tooltip,
    super.key,
  });

  final String label;
  final String value;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return content;
    }
    return Tooltip(message: tooltip!, child: content);
  }
}
