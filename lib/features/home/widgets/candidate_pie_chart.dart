import 'dart:math';

import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class CandidatePieChart extends StatelessWidget {
  const CandidatePieChart({required this.candidates, super.key});

  final List<TranslationCandidate> candidates;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }
    final topCandidate = candidates.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 164,
          height: 164,
          child: CustomPaint(
            painter: _PiePainter(
              candidates,
              Theme.of(context).colorScheme.surface,
            ),
            child: const Center(child: SizedBox.shrink()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExpressionCard(candidate: topCandidate),
              const SizedBox(height: 14),
              ...List.generate(candidates.length, (index) {
                final candidate = candidates[index];
                final color = _chartColor(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(candidate.intent.labelJa)),
                      Text('${(candidate.score * 100).round()}%'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpressionCard extends StatelessWidget {
  const _ExpressionCard({required this.candidate});

  final TranslationCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expression = _expressionForIntent(candidate.intent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: expression.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              expression.icon,
              size: 34,
              color: expression.foregroundColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('表情イメージ', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  expression.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${candidate.intent.labelJa} に近い反応',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpressionVisual {
  const _ExpressionVisual({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}

_ExpressionVisual _expressionForIntent(DogIntent intent) {
  switch (intent) {
    case DogIntent.excitedGreeting:
      return const _ExpressionVisual(
        icon: Icons.sentiment_very_satisfied,
        label: 'うれしそう',
        backgroundColor: Color(0xFFFFF3C4),
        foregroundColor: Color(0xFFB45309),
      );
    case DogIntent.attentionSeeking:
      return const _ExpressionVisual(
        icon: Icons.sentiment_satisfied,
        label: 'かまってほしそう',
        backgroundColor: Color(0xFFDBEAFE),
        foregroundColor: Color(0xFF1D4ED8),
      );
    case DogIntent.warningAlert:
      return const _ExpressionVisual(
        icon: Icons.sentiment_very_dissatisfied,
        label: '警戒していそう',
        backgroundColor: Color(0xFFFEE2E2),
        foregroundColor: Color(0xFFB91C1C),
      );
    case DogIntent.anxiousWhine:
      return const _ExpressionVisual(
        icon: Icons.sentiment_dissatisfied,
        label: '不安そう',
        backgroundColor: Color(0xFFEDE9FE),
        foregroundColor: Color(0xFF6D28D9),
      );
    case DogIntent.sleepy:
      return const _ExpressionVisual(
        icon: Icons.bedtime,
        label: 'ねむたそう',
        backgroundColor: Color(0xFFE0F2FE),
        foregroundColor: Color(0xFF0369A1),
      );
    case DogIntent.restlessEnergy:
      return const _ExpressionVisual(
        icon: Icons.psychology_alt,
        label: 'そわそわしていそう',
        backgroundColor: Color(0xFFFEF3C7),
        foregroundColor: Color(0xFFB45309),
      );
    case DogIntent.happyRelaxed:
      return const _ExpressionVisual(
        icon: Icons.sentiment_satisfied_alt,
        label: '落ち着いていそう',
        backgroundColor: Color(0xFFDCFCE7),
        foregroundColor: Color(0xFF15803D),
      );
    case DogIntent.bored:
      return const _ExpressionVisual(
        icon: Icons.sentiment_neutral,
        label: '退屈そう',
        backgroundColor: Color(0xFFE5E7EB),
        foregroundColor: Color(0xFF4B5563),
      );
    case DogIntent.uncertain:
      return const _ExpressionVisual(
        icon: Icons.help_outline,
        label: '判断が難しい',
        backgroundColor: Color(0xFFE2E8F0),
        foregroundColor: Color(0xFF475569),
      );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.candidates, this.innerColor);

  final List<TranslationCandidate> candidates;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = candidates.fold<double>(0, (sum, item) => sum + item.score);
    var startAngle = -pi / 2;

    for (var i = 0; i < candidates.length; i++) {
      final candidate = candidates[i];
      final sweep = total <= 0 ? 0.0 : (candidate.score / total) * (pi * 2);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.butt
        ..color = _chartColor(i);
      canvas.drawArc(rect.deflate(14), startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final innerPaint = Paint()..color = innerColor;
    canvas.drawCircle(center, radius - 24, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.candidates != candidates ||
        oldDelegate.innerColor != innerColor;
  }
}

Color _chartColor(int index) {
  const colors = <Color>[
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFFF59E0B),
    Color(0xFF9333EA),
  ];
  return colors[index % colors.length];
}
