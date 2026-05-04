import 'dart:math';

import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class CandidatePieChart extends StatelessWidget {
  const CandidatePieChart({
    required this.candidates,
    required this.breed,
    super.key,
  });

  final List<TranslationCandidate> candidates;
  final DogBreed breed;

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
              _ExpressionCard(candidate: topCandidate, breed: breed),
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
  const _ExpressionCard({required this.candidate, required this.breed});

  final TranslationCandidate candidate;
  final DogBreed breed;

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
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: expression.backgroundColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                _expressionAssetPath(breed, candidate.intent),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CustomPaint(
                    painter: _DogFacePainter(expression: expression),
                    child: const SizedBox.expand(),
                  );
                },
              ),
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

String _expressionAssetPath(DogBreed breed, DogIntent intent) {
  return 'assets/expression_icons/${_breedKey(breed)}_${_intentKey(intent)}.png';
}

String _breedKey(DogBreed breed) {
  return switch (breed) {
    DogBreed.mixed => 'mixed',
    DogBreed.shiba => 'shiba',
    DogBreed.chihuahua => 'chihuahua',
    DogBreed.toyPoodle => 'toy_poodle',
    DogBreed.goldenRetriever => 'golden_retriever',
    DogBreed.husky => 'husky',
    DogBreed.pomeranian => 'pomeranian',
  };
}

String _intentKey(DogIntent intent) {
  return switch (intent) {
    DogIntent.excitedGreeting => 'excited_greeting',
    DogIntent.attentionSeeking => 'attention_seeking',
    DogIntent.happyRelaxed => 'happy_relaxed',
    DogIntent.warningAlert => 'warning_alert',
    DogIntent.anxiousWhine => 'anxious_whine',
    DogIntent.sleepy => 'sleepy',
    DogIntent.restlessEnergy => 'restless_energy',
    DogIntent.bored => 'bored',
    DogIntent.uncertain => 'uncertain',
  };
}

class _ExpressionVisual {
  const _ExpressionVisual({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.eyeStyle,
    required this.mouthStyle,
    required this.earStyle,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final _DogEyeStyle eyeStyle;
  final _DogMouthStyle mouthStyle;
  final _DogEarStyle earStyle;
}

_ExpressionVisual _expressionForIntent(DogIntent intent) {
  switch (intent) {
    case DogIntent.excitedGreeting:
      return const _ExpressionVisual(
        label: 'うれしそう',
        backgroundColor: Color(0xFFFFF3C4),
        foregroundColor: Color(0xFFB45309),
        eyeStyle: _DogEyeStyle.happyArc,
        mouthStyle: _DogMouthStyle.openSmile,
        earStyle: _DogEarStyle.perky,
      );
    case DogIntent.attentionSeeking:
      return const _ExpressionVisual(
        label: 'かまってほしそう',
        backgroundColor: Color(0xFFDBEAFE),
        foregroundColor: Color(0xFF1D4ED8),
        eyeStyle: _DogEyeStyle.round,
        mouthStyle: _DogMouthStyle.softSmile,
        earStyle: _DogEarStyle.perky,
      );
    case DogIntent.warningAlert:
      return const _ExpressionVisual(
        label: '警戒していそう',
        backgroundColor: Color(0xFFFEE2E2),
        foregroundColor: Color(0xFFB91C1C),
        eyeStyle: _DogEyeStyle.alert,
        mouthStyle: _DogMouthStyle.flat,
        earStyle: _DogEarStyle.sharp,
      );
    case DogIntent.anxiousWhine:
      return const _ExpressionVisual(
        label: '不安そう',
        backgroundColor: Color(0xFFEDE9FE),
        foregroundColor: Color(0xFF6D28D9),
        eyeStyle: _DogEyeStyle.sad,
        mouthStyle: _DogMouthStyle.worried,
        earStyle: _DogEarStyle.droopy,
      );
    case DogIntent.sleepy:
      return const _ExpressionVisual(
        label: 'ねむたそう',
        backgroundColor: Color(0xFFE0F2FE),
        foregroundColor: Color(0xFF0369A1),
        eyeStyle: _DogEyeStyle.sleepy,
        mouthStyle: _DogMouthStyle.softSmile,
        earStyle: _DogEarStyle.relaxed,
      );
    case DogIntent.restlessEnergy:
      return const _ExpressionVisual(
        label: 'そわそわしていそう',
        backgroundColor: Color(0xFFFEF3C7),
        foregroundColor: Color(0xFFB45309),
        eyeStyle: _DogEyeStyle.round,
        mouthStyle: _DogMouthStyle.openSmile,
        earStyle: _DogEarStyle.sharp,
      );
    case DogIntent.happyRelaxed:
      return const _ExpressionVisual(
        label: '落ち着いていそう',
        backgroundColor: Color(0xFFDCFCE7),
        foregroundColor: Color(0xFF15803D),
        eyeStyle: _DogEyeStyle.happyArc,
        mouthStyle: _DogMouthStyle.softSmile,
        earStyle: _DogEarStyle.relaxed,
      );
    case DogIntent.bored:
      return const _ExpressionVisual(
        label: '退屈そう',
        backgroundColor: Color(0xFFE5E7EB),
        foregroundColor: Color(0xFF4B5563),
        eyeStyle: _DogEyeStyle.sleepy,
        mouthStyle: _DogMouthStyle.flat,
        earStyle: _DogEarStyle.relaxed,
      );
    case DogIntent.uncertain:
      return const _ExpressionVisual(
        label: '判断が難しい',
        backgroundColor: Color(0xFFE2E8F0),
        foregroundColor: Color(0xFF475569),
        eyeStyle: _DogEyeStyle.round,
        mouthStyle: _DogMouthStyle.worried,
        earStyle: _DogEarStyle.droopy,
      );
  }
}

enum _DogEyeStyle { round, happyArc, alert, sad, sleepy }

enum _DogMouthStyle { softSmile, openSmile, flat, worried }

enum _DogEarStyle { perky, sharp, droopy, relaxed }

class _DogFacePainter extends CustomPainter {
  const _DogFacePainter({required this.expression});

  final _ExpressionVisual expression;

  @override
  void paint(Canvas canvas, Size size) {
    final faceColor = Colors.white.withValues(alpha: 0.95);
    final outline = Paint()
      ..color = expression.foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    final accent = Paint()
      ..color = expression.foregroundColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2 + 2);
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.58,
        height: size.height * 0.5,
      ),
      const Radius.circular(18),
    );

    _drawEars(canvas, size, fill, outline);
    canvas.drawRRect(faceRect, fill);
    canvas.drawRRect(faceRect, outline);

    final eyeY = size.height * 0.43;
    final leftEye = Offset(size.width * 0.38, eyeY);
    final rightEye = Offset(size.width * 0.62, eyeY);
    _drawEye(canvas, leftEye, expression.eyeStyle, outline, accent);
    _drawEye(canvas, rightEye, expression.eyeStyle, outline, accent);

    final noseCenter = Offset(size.width * 0.5, size.height * 0.56);
    final nose = Path()
      ..moveTo(noseCenter.dx, noseCenter.dy + 3)
      ..lineTo(noseCenter.dx - 5, noseCenter.dy - 3)
      ..lineTo(noseCenter.dx + 5, noseCenter.dy - 3)
      ..close();
    canvas.drawPath(nose, accent);

    final snoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.67),
        width: size.width * 0.24,
        height: size.height * 0.16,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(snoutRect, fill);
    canvas.drawRRect(snoutRect, outline);
    canvas.drawLine(
      Offset(noseCenter.dx, noseCenter.dy + 1),
      Offset(noseCenter.dx, size.height * 0.62),
      outline,
    );
    _drawMouth(canvas, size, expression.mouthStyle, outline, accent);
  }

  void _drawEars(Canvas canvas, Size size, Paint fill, Paint outline) {
    final leftEar = Path();
    final rightEar = Path();
    switch (expression.earStyle) {
      case _DogEarStyle.perky:
      case _DogEarStyle.sharp:
        final tipY = expression.earStyle == _DogEarStyle.sharp ? 0.08 : 0.12;
        leftEar
          ..moveTo(size.width * 0.28, size.height * 0.28)
          ..lineTo(size.width * 0.18, size.height * tipY)
          ..lineTo(size.width * 0.35, size.height * 0.2)
          ..close();
        rightEar
          ..moveTo(size.width * 0.72, size.height * 0.28)
          ..lineTo(size.width * 0.82, size.height * tipY)
          ..lineTo(size.width * 0.65, size.height * 0.2)
          ..close();
        break;
      case _DogEarStyle.droopy:
        leftEar
          ..moveTo(size.width * 0.3, size.height * 0.24)
          ..quadraticBezierTo(
            size.width * 0.12,
            size.height * 0.26,
            size.width * 0.22,
            size.height * 0.46,
          )
          ..lineTo(size.width * 0.36, size.height * 0.26)
          ..close();
        rightEar
          ..moveTo(size.width * 0.7, size.height * 0.24)
          ..quadraticBezierTo(
            size.width * 0.88,
            size.height * 0.26,
            size.width * 0.78,
            size.height * 0.46,
          )
          ..lineTo(size.width * 0.64, size.height * 0.26)
          ..close();
        break;
      case _DogEarStyle.relaxed:
        leftEar
          ..moveTo(size.width * 0.3, size.height * 0.22)
          ..quadraticBezierTo(
            size.width * 0.18,
            size.height * 0.14,
            size.width * 0.25,
            size.height * 0.34,
          )
          ..lineTo(size.width * 0.36, size.height * 0.22)
          ..close();
        rightEar
          ..moveTo(size.width * 0.7, size.height * 0.22)
          ..quadraticBezierTo(
            size.width * 0.82,
            size.height * 0.14,
            size.width * 0.75,
            size.height * 0.34,
          )
          ..lineTo(size.width * 0.64, size.height * 0.22)
          ..close();
        break;
    }
    canvas.drawPath(leftEar, fill);
    canvas.drawPath(rightEar, fill);
    canvas.drawPath(leftEar, outline);
    canvas.drawPath(rightEar, outline);
  }

  void _drawEye(
    Canvas canvas,
    Offset center,
    _DogEyeStyle style,
    Paint outline,
    Paint accent,
  ) {
    switch (style) {
      case _DogEyeStyle.round:
        canvas.drawCircle(center, 2.4, accent);
        break;
      case _DogEyeStyle.alert:
        canvas.drawOval(
          Rect.fromCenter(center: center, width: 7, height: 4.5),
          accent,
        );
        break;
      case _DogEyeStyle.happyArc:
        final path = Path()
          ..moveTo(center.dx - 4, center.dy + 1)
          ..quadraticBezierTo(
            center.dx,
            center.dy - 3,
            center.dx + 4,
            center.dy + 1,
          );
        canvas.drawPath(path, outline);
        break;
      case _DogEyeStyle.sad:
        final path = Path()
          ..moveTo(center.dx - 4, center.dy - 1)
          ..quadraticBezierTo(
            center.dx,
            center.dy + 3,
            center.dx + 4,
            center.dy - 1,
          );
        canvas.drawPath(path, outline);
        break;
      case _DogEyeStyle.sleepy:
        canvas.drawLine(
          Offset(center.dx - 4, center.dy),
          Offset(center.dx + 4, center.dy),
          outline,
        );
        break;
    }
  }

  void _drawMouth(
    Canvas canvas,
    Size size,
    _DogMouthStyle style,
    Paint outline,
    Paint accent,
  ) {
    final centerY = size.height * 0.71;
    switch (style) {
      case _DogMouthStyle.softSmile:
        final path = Path()
          ..moveTo(size.width * 0.44, centerY)
          ..quadraticBezierTo(
            size.width * 0.5,
            centerY + 6,
            size.width * 0.56,
            centerY,
          );
        canvas.drawPath(path, outline);
        break;
      case _DogMouthStyle.openSmile:
        final path = Path()
          ..moveTo(size.width * 0.43, centerY - 1)
          ..quadraticBezierTo(
            size.width * 0.5,
            centerY + 8,
            size.width * 0.57,
            centerY - 1,
          )
          ..quadraticBezierTo(
            size.width * 0.5,
            centerY + 12,
            size.width * 0.43,
            centerY - 1,
          );
        canvas.drawPath(path, accent);
        break;
      case _DogMouthStyle.flat:
        canvas.drawLine(
          Offset(size.width * 0.44, centerY),
          Offset(size.width * 0.56, centerY),
          outline,
        );
        break;
      case _DogMouthStyle.worried:
        final path = Path()
          ..moveTo(size.width * 0.44, centerY + 4)
          ..quadraticBezierTo(
            size.width * 0.5,
            centerY - 4,
            size.width * 0.56,
            centerY + 4,
          );
        canvas.drawPath(path, outline);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DogFacePainter oldDelegate) {
    return oldDelegate.expression != expression;
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
