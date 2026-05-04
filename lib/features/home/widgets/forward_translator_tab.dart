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
                              tooltip: 'どの推論方式で結果を出したかを表示します。',
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
                              tooltip: '犬の声の種類を推定した結果です。',
                            ),
                            FeatureChip(
                              label: '文脈',
                              value: result!.context.labelJa,
                              tooltip: 'どのような状況に近いかの推定です。',
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
                          const Text('大きな録音品質上の注意は見つかりませんでした。')
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
        _MetricBar(
          label: 'RMS',
          valueLabel: result.features.rms.toStringAsFixed(3),
          normalizedValue: result.features.rms.clamp(0.0, 1.0),
          minLabel: '0.0',
          maxLabel: '1.0',
        ),
        _MetricBar(
          label: 'Peak',
          valueLabel: result.features.peak.toStringAsFixed(3),
          normalizedValue: result.features.peak.clamp(0.0, 1.0),
          minLabel: '0.0',
          maxLabel: '1.0',
        ),
        _MetricBar(
          label: 'Arousal',
          valueLabel: result.arousal.toStringAsFixed(2),
          normalizedValue: result.arousal.clamp(0.0, 1.0),
          minLabel: '0.0',
          maxLabel: '1.0',
        ),
        _MetricBar(
          label: 'Valence',
          valueLabel: result.valence.toStringAsFixed(2),
          normalizedValue: ((result.valence + 1) / 2).clamp(0.0, 1.0),
          minLabel: '-1.0',
          maxLabel: '1.0',
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.valueLabel,
    required this.normalizedValue,
    required this.minLabel,
    required this.maxLabel,
  });

  final String label;
  final String valueLabel;
  final double normalizedValue;
  final String minLabel;
  final String maxLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(valueLabel, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: normalizedValue,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(minLabel, style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              Text(maxLabel, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
