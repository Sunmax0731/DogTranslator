import 'package:flutter/material.dart';

class WaveformPanel extends StatelessWidget {
  const WaveformPanel({
    required this.isRecording,
    required this.waveformSamples,
    super.key,
  });

  final bool isRecording;
  final List<double> waveformSamples;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRecording ? '録音波形' : '録音待機中',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: waveformSamples.isEmpty
                ? Center(
                    child: Text(
                      '録音を開始すると波形を表示します。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : CustomPaint(
                    painter: _WaveformPainter(samples: waveformSamples),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.samples});

  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    final baselinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / (samples.length * 1.8);

    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      baselinePaint,
    );

    if (samples.isEmpty) {
      return;
    }

    final step = size.width / samples.length;
    for (var i = 0; i < samples.length; i++) {
      final amplitude = samples[i].clamp(0.0, 1.0);
      final barHeight = (size.height * 0.45) * amplitude;
      final x = (i * step) + (step / 2);
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    if (oldDelegate.samples.length != samples.length) {
      return true;
    }
    for (var i = 0; i < samples.length; i++) {
      if (oldDelegate.samples[i] != samples[i]) {
        return true;
      }
    }
    return false;
  }
}
