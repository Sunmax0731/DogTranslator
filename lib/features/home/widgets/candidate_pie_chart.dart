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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 164,
          height: 164,
          child: CustomPaint(
            painter: _PiePainter(candidates),
            child: const Center(child: SizedBox.shrink()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(candidates.length, (index) {
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
          ),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.candidates);

  final List<TranslationCandidate> candidates;

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

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - 24, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.candidates != candidates;
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
