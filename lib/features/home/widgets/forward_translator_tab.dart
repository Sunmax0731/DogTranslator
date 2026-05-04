import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/features/home/widgets/candidate_pie_chart.dart';
import 'package:dog_translator/features/home/widgets/feature_chip.dart';
import 'package:dog_translator/features/home/widgets/waveform_panel.dart';
import 'package:flutter/material.dart';

class ForwardTranslatorTab extends StatelessWidget {
  const ForwardTranslatorTab({
    required this.result,
    required this.latestRecord,
    required this.isRecording,
    required this.busy,
    required this.analysisInProgress,
    required this.analysisProgress,
    required this.analysisStageMessage,
    required this.analysisEstimatedRemainingLabel,
    required this.statusMessage,
    required this.waveformSamples,
    required this.profiles,
    required this.selectedProfileId,
    required this.selectedSceneMode,
    required this.onProfileChanged,
    required this.onCreateProfilePressed,
    required this.onSceneModeChanged,
    required this.onRecordPressed,
    required this.onFeedbackChanged,
    super.key,
  });

  final TranslationResult? result;
  final ForwardRecord? latestRecord;
  final bool isRecording;
  final bool busy;
  final bool analysisInProgress;
  final double? analysisProgress;
  final String? analysisStageMessage;
  final String? analysisEstimatedRemainingLabel;
  final String? statusMessage;
  final List<double> waveformSamples;
  final List<DogProfile> profiles;
  final String? selectedProfileId;
  final SceneMode selectedSceneMode;
  final ValueChanged<String?> onProfileChanged;
  final VoidCallback onCreateProfilePressed;
  final ValueChanged<SceneMode?> onSceneModeChanged;
  final VoidCallback onRecordPressed;
  final ValueChanged<UserFeedbackLabel?> onFeedbackChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('犬の鳴き声を録音して、感情や意図を推定します。'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedProfileId,
                        decoration: const InputDecoration(
                          labelText: 'プロフィール',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('プロフィール未選択'),
                          ),
                          ...profiles.map(
                            (profile) => DropdownMenuItem<String?>(
                              value: profile.id,
                              child: Text(profile.name),
                            ),
                          ),
                        ],
                        onChanged: busy || isRecording
                            ? null
                            : onProfileChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: busy || isRecording
                          ? null
                          : onCreateProfilePressed,
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SceneMode>(
                  initialValue: selectedSceneMode,
                  decoration: const InputDecoration(
                    labelText: 'シーン',
                    border: OutlineInputBorder(),
                  ),
                  items: SceneMode.values
                      .map(
                        (mode) => DropdownMenuItem<SceneMode>(
                          value: mode,
                          child: Text(mode.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy || isRecording ? null : onSceneModeChanged,
                ),
                const SizedBox(height: 16),
                WaveformPanel(
                  isRecording: isRecording,
                  waveformSamples: waveformSamples,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy ? null : onRecordPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: isRecording
                        ? const Color(0xFFB91C1C)
                        : colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                  icon: Icon(isRecording ? Icons.stop_circle : Icons.mic),
                  label: Text(isRecording ? '録音を止めて解析' : '録音を開始'),
                ),
                if (analysisInProgress) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: analysisProgress,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    analysisStageMessage ?? '解析しています...',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  if (analysisEstimatedRemainingLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      analysisEstimatedRemainingLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Text(
                  statusMessage ?? 'マイクボタンを押して録音を始めてください。',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: analysisInProgress ? 0.5 : 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: result == null
                  ? const Text('まだ解析結果がありません。録音後にここへ結果を表示します。')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result!.intent.labelJa,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(result!.explanation),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FeatureChip(
                              label: '推論方式',
                              value: result!.providerLabel,
                              tooltip: 'どの推論方式で結果を算出したかを示します。',
                            ),
                            FeatureChip(
                              label: '確信度',
                              value: result!.confidence.labelJa,
                              tooltip: '推論結果の確からしさの目安です。',
                              backgroundColor: _confidenceBackground(
                                result!.confidence,
                              ),
                              foregroundColor: _confidenceForeground(
                                result!.confidence,
                              ),
                            ),
                            FeatureChip(
                              label: '鳴き方',
                              value: result!.vocalType.labelJa,
                              tooltip: '犬の声の出し方を分類した結果です。',
                            ),
                            FeatureChip(
                              label: '文脈',
                              value: result!.context.labelJa,
                              tooltip: 'どのような場面に近いかの推定です。',
                            ),
                            FeatureChip(
                              label: '録音長',
                              value:
                                  '${result!.features.durationSeconds.toStringAsFixed(2)}s',
                              tooltip: '録音した音声の長さです。',
                            ),
                            FeatureChip(
                              label: 'Pitch',
                              value: result!.features.pitchHz.toStringAsFixed(
                                0,
                              ),
                              tooltip: '主な高さの推定値です。',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _MetricRangePanel(result: result!),
                        const SizedBox(height: 20),
                        Text(
                          '推論候補',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        CandidatePieChart(candidates: result!.candidates),
                        const SizedBox(height: 20),
                        Text(
                          '録音品質ガイド',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (result!.qualityIssues.isEmpty)
                          const Text('大きな録音品質上の問題は見つかりませんでした。')
                        else
                          ...result!.qualityIssues.map(
                            (issue) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '・${issue.labelJa} - ${issue.adviceJa}',
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          '推論の近さを記録',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        RadioGroup<UserFeedbackLabel>(
                          groupValue: latestRecord?.feedbackLabel,
                          onChanged: onFeedbackChanged,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: UserFeedbackLabel.values
                                .map(
                                  (label) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<UserFeedbackLabel>(value: label),
                                      Text(label.labelJa),
                                    ],
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Color _confidenceBackground(ConfidenceLevel level) {
    return switch (level) {
      ConfidenceLevel.high => const Color(0xFFDCFCE7),
      ConfidenceLevel.medium => const Color(0xFFFEF3C7),
      ConfidenceLevel.low => const Color(0xFFFEE2E2),
    };
  }

  Color _confidenceForeground(ConfidenceLevel level) {
    return switch (level) {
      ConfidenceLevel.high => const Color(0xFF166534),
      ConfidenceLevel.medium => const Color(0xFF92400E),
      ConfidenceLevel.low => const Color(0xFF991B1B),
    };
  }
}

class _MetricRangePanel extends StatelessWidget {
  const _MetricRangePanel({required this.result});

  final TranslationResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('主要パラメータ', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 12.0;
            final cardWidth = constraints.maxWidth > 560
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _MetricBar(
                    label: 'RMS',
                    tooltip: '音量エネルギーの平均的な強さです。0 に近いほど小さく、1 に近いほど強い入力です。',
                    valueLabel: result.features.rms.toStringAsFixed(3),
                    normalizedValue: result.features.rms.clamp(0.0, 1.0),
                    minLabel: '0.0',
                    maxLabel: '1.0',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _MetricBar(
                    label: 'Peak',
                    tooltip: '録音内の最大瞬間音量です。突発的な強い鳴き声やノイズで上がります。',
                    valueLabel: result.features.peak.toStringAsFixed(3),
                    normalizedValue: result.features.peak.clamp(0.0, 1.0),
                    minLabel: '0.0',
                    maxLabel: '1.0',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _MetricBar(
                    label: 'Arousal',
                    tooltip: '興奮や活発さの推定値です。0 に近いほど落ち着き、1 に近いほど高ぶり傾向です。',
                    valueLabel: result.arousal.toStringAsFixed(2),
                    normalizedValue: result.arousal.clamp(0.0, 1.0),
                    minLabel: '0.0',
                    maxLabel: '1.0',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _MetricBar(
                    label: 'Valence',
                    tooltip: '感情の快不快傾向です。負側は不快・警戒寄り、正側は快・親和寄りです。',
                    valueLabel: result.valence.toStringAsFixed(2),
                    normalizedValue: ((result.valence + 1) / 2).clamp(0.0, 1.0),
                    minLabel: '-1.0',
                    maxLabel: '1.0',
                    showZeroMarker: true,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.tooltip,
    required this.valueLabel,
    required this.normalizedValue,
    required this.minLabel,
    required this.maxLabel,
    this.showZeroMarker = false,
  });

  final String label;
  final String tooltip;
  final String valueLabel;
  final double normalizedValue;
  final String minLabel;
  final String maxLabel;
  final bool showZeroMarker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = Color.lerp(
      const Color(0xFFDC2626),
      const Color(0xFF16A34A),
      normalizedValue,
    )!;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 250),
      showDuration: const Duration(seconds: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label, style: theme.textTheme.titleSmall),
                  ),
                  Text(valueLabel, style: theme.textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 16,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final markerLeft = constraints.maxWidth * normalizedValue;
                    final zeroLeft = constraints.maxWidth * 0.5;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFDC2626),
                                Color(0xFFF59E0B),
                                Color(0xFF16A34A),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: markerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              colors: [
                                indicatorColor.withValues(alpha: 0.55),
                                indicatorColor,
                              ],
                            ),
                          ),
                        ),
                        if (showZeroMarker)
                          Positioned(
                            left: (zeroLeft - 1.5).clamp(
                              0.0,
                              constraints.maxWidth - 3,
                            ),
                            top: -3,
                            bottom: -3,
                            child: Container(
                              width: 3,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        Positioned(
                          left: (markerLeft - 7).clamp(
                            0.0,
                            constraints.maxWidth - 14,
                          ),
                          top: -3,
                          child: Container(
                            width: 14,
                            height: 22,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: indicatorColor,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(minLabel, style: theme.textTheme.labelSmall),
                  if (showZeroMarker) ...[
                    const Spacer(),
                    Text('0', style: theme.textTheme.labelSmall),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  Text(maxLabel, style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
