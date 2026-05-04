import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({
    required this.selectedThemePreset,
    required this.selectedInferenceModel,
    required this.inferenceStatusMessage,
    required this.inputDevices,
    required this.selectedInputDeviceId,
    required this.loadingInputDevices,
    required this.profiles,
    required this.latestForwardRecord,
    required this.onThemeChanged,
    required this.onInferenceModelChanged,
    required this.onInputDeviceChanged,
    required this.onRefreshInputDevices,
    required this.onCreateProfilePressed,
    required this.onEditProfilePressed,
    required this.onDeleteProfilePressed,
    required this.onAddCalibrationSamplePressed,
    super.key,
  });

  final AppThemePreset selectedThemePreset;
  final InferenceModelSelection selectedInferenceModel;
  final String? inferenceStatusMessage;
  final List<RecordingInputDevice> inputDevices;
  final String? selectedInputDeviceId;
  final bool loadingInputDevices;
  final List<DogProfile> profiles;
  final ForwardRecord? latestForwardRecord;
  final ValueChanged<AppThemePreset?> onThemeChanged;
  final ValueChanged<InferenceModelSelection?> onInferenceModelChanged;
  final ValueChanged<String?> onInputDeviceChanged;
  final VoidCallback onRefreshInputDevices;
  final VoidCallback onCreateProfilePressed;
  final ValueChanged<DogProfile> onEditProfilePressed;
  final ValueChanged<String> onDeleteProfilePressed;
  final ValueChanged<String> onAddCalibrationSamplePressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppThemePreset>(
                  initialValue: selectedThemePreset,
                  decoration: const InputDecoration(
                    labelText: 'カラーテーマ',
                    border: OutlineInputBorder(),
                  ),
                  items: AppThemePreset.values
                      .map(
                        (preset) => DropdownMenuItem<AppThemePreset>(
                          value: preset,
                          child: Text(preset.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: onThemeChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<InferenceModelSelection>(
                  initialValue: selectedInferenceModel,
                  decoration: const InputDecoration(
                    labelText: '推論モデル',
                    border: OutlineInputBorder(),
                  ),
                  items: InferenceModelSelection.values
                      .map(
                        (selection) =>
                            DropdownMenuItem<InferenceModelSelection>(
                              value: selection,
                              child: Text(selection.labelJa),
                            ),
                      )
                      .toList(growable: false),
                  onChanged: onInferenceModelChanged,
                ),
                const SizedBox(height: 8),
                Text(
                  inferenceStatusMessage ??
                      selectedInferenceModel.descriptionJa,
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
                        onChanged: loadingInputDevices
                            ? null
                            : onInputDeviceChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'マイク一覧を更新',
                      onPressed: loadingInputDevices
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'プロフィール管理',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onCreateProfilePressed,
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (profiles.isEmpty)
                  const Text('まだプロフィールがありません。')
                else
                  ...profiles.map(
                    (profile) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProfileTile(
                        profile: profile,
                        canAddSample:
                            latestForwardRecord != null &&
                            latestForwardRecord!.profileId == profile.id,
                        onEditPressed: () => onEditProfilePressed(profile),
                        onDeletePressed: () =>
                            onDeleteProfilePressed(profile.id),
                        onAddSamplePressed: () =>
                            onAddCalibrationSamplePressed(profile.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.canAddSample,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onAddSamplePressed,
  });

  final DogProfile profile;
  final bool canAddSample;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onAddSamplePressed;

  @override
  Widget build(BuildContext context) {
    final calibration = profile.voiceCalibration;
    final detailStyle = Theme.of(context).textTheme.bodySmall;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onDeletePressed,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Text(
            '${profile.breed.labelJa} / ${profile.ageStage.labelJa} / ${profile.sizeClass.labelJa}',
          ),
          if (profile.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(profile.notes, style: detailStyle),
          ],
          const SizedBox(height: 8),
          Text(
            calibration == null
                ? '個体サンプル: まだありません'
                : '個体サンプル: ${calibration.sampleCount}件 / 平均 Pitch ${calibration.averagePitchHz.toStringAsFixed(0)} Hz',
            style: detailStyle,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: canAddSample ? onAddSamplePressed : null,
            icon: const Icon(Icons.graphic_eq),
            label: const Text('最新録音を個体サンプルに追加'),
          ),
        ],
      ),
    );
  }
}
