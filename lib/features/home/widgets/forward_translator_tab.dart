import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/features/home/widgets/feature_chip.dart';
import 'package:dog_translator/features/home/widgets/waveform_panel.dart';
import 'package:flutter/material.dart';

class ForwardTranslatorTab extends StatelessWidget {
  const ForwardTranslatorTab({
    required this.result,
    required this.latestRecord,
    required this.isRecording,
    required this.busy,
    required this.loadingInputDevices,
    required this.statusMessage,
    required this.waveformSamples,
    required this.inputDevices,
    required this.selectedInputDeviceId,
    required this.profiles,
    required this.selectedProfileId,
    required this.selectedSceneMode,
    required this.onProfileChanged,
    required this.onCreateProfilePressed,
    required this.onSceneModeChanged,
    required this.onInputDeviceSelected,
    required this.onRefreshInputDevices,
    required this.onRecordPressed,
    required this.onFeedbackChanged,
    super.key,
  });

  final TranslationResult? result;
  final ForwardRecord? latestRecord;
  final bool isRecording;
  final bool busy;
  final bool loadingInputDevices;
  final String? statusMessage;
  final List<double> waveformSamples;
  final List<RecordingInputDevice> inputDevices;
  final String? selectedInputDeviceId;
  final List<DogProfile> profiles;
  final String? selectedProfileId;
  final SceneMode selectedSceneMode;
  final ValueChanged<String?> onProfileChanged;
  final VoidCallback onCreateProfilePressed;
  final ValueChanged<SceneMode?> onSceneModeChanged;
  final ValueChanged<String?> onInputDeviceSelected;
  final VoidCallback onRefreshInputDevices;
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
                Text(
                  'Forward Interpretation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('録音した犬の声から、感情や意図の傾向を日本語で推定します。'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedProfileId,
                        decoration: const InputDecoration(
                          labelText: '犬プロフィール',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedInputDeviceId,
                        decoration: const InputDecoration(
                          labelText: '入力マイク',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('既定のマイク'),
                          ),
                          ...inputDevices.map(
                            (device) => DropdownMenuItem<String?>(
                              value: device.id,
                              child: Text(device.label),
                            ),
                          ),
                        ],
                        onChanged: loadingInputDevices || busy || isRecording
                            ? null
                            : onInputDeviceSelected,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'マイク一覧を更新',
                      onPressed: loadingInputDevices || busy || isRecording
                          ? null
                          : onRefreshInputDevices,
                      icon: loadingInputDevices
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ],
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
        Card(
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
                            label: '確信度',
                            value: result!.confidence.labelJa,
                          ),
                          FeatureChip(
                            label: '録音長',
                            value:
                                '${result!.features.durationSeconds.toStringAsFixed(2)}s',
                          ),
                          FeatureChip(
                            label: 'RMS',
                            value: result!.features.rms.toStringAsFixed(3),
                          ),
                          FeatureChip(
                            label: 'Peak',
                            value: result!.features.peak.toStringAsFixed(3),
                          ),
                          FeatureChip(
                            label: 'Burst',
                            value: result!.features.burstCount.toString(),
                          ),
                          FeatureChip(
                            label: 'Spectral',
                            value: result!.features.spectralCentroid
                                .toStringAsFixed(0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '候補',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...result!.candidates.map(
                        (candidate) => Text(
                          '${candidate.intent.labelJa} - ${(candidate.score * 100).round()}%',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '録音品質ガイド',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (result!.qualityIssues.isEmpty)
                        const Text('大きな録音品質の問題は見つかりませんでした。')
                      else
                        ...result!.qualityIssues.map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '・${issue.labelJa} - ${issue.adviceJa}',
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<UserFeedbackLabel>(
                        initialValue: latestRecord?.feedbackLabel,
                        decoration: const InputDecoration(
                          labelText: '推定の近さを記録',
                          border: OutlineInputBorder(),
                        ),
                        items: UserFeedbackLabel.values
                            .map(
                              (label) => DropdownMenuItem<UserFeedbackLabel>(
                                value: label,
                                child: Text(label.labelJa),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: onFeedbackChanged,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
