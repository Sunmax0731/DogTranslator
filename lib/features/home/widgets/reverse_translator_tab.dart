import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class ReverseTranslatorTab extends StatelessWidget {
  const ReverseTranslatorTab({
    required this.controller,
    required this.result,
    required this.busy,
    required this.profiles,
    required this.selectedProfileId,
    required this.selectedBreed,
    required this.selectedAgeStage,
    required this.selectedSizeClass,
    required this.selectedTension,
    required this.selectedSceneMode,
    required this.statusMessage,
    required this.onProfileChanged,
    required this.onSceneModeChanged,
    required this.onBreedChanged,
    required this.onAgeStageChanged,
    required this.onSizeClassChanged,
    required this.onTensionChanged,
    required this.onTranslatePressed,
    super.key,
  });

  final TextEditingController controller;
  final ReverseTranslationResult? result;
  final bool busy;
  final List<DogProfile> profiles;
  final String? selectedProfileId;
  final DogBreed selectedBreed;
  final DogAgeStage selectedAgeStage;
  final DogSizeClass selectedSizeClass;
  final TensionLevel selectedTension;
  final SceneMode selectedSceneMode;
  final String? statusMessage;
  final ValueChanged<String?> onProfileChanged;
  final ValueChanged<SceneMode?> onSceneModeChanged;
  final ValueChanged<DogBreed?> onBreedChanged;
  final ValueChanged<DogAgeStage?> onAgeStageChanged;
  final ValueChanged<DogSizeClass?> onSizeClassChanged;
  final ValueChanged<TensionLevel?> onTensionChanged;
  final VoidCallback onTranslatePressed;

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
                Text(
                  'Reverse Expression',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('人の言葉を犬っぽい表現と音声に変換します。犬種、年齢、サイズ、テンションを調整できます。'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
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
                  onChanged: busy ? null : onProfileChanged,
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
                  onChanged: busy ? null : onSceneModeChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DogBreed>(
                  initialValue: selectedBreed,
                  decoration: const InputDecoration(
                    labelText: '犬種プリセット',
                    border: OutlineInputBorder(),
                  ),
                  items: DogBreed.values
                      .map(
                        (breed) => DropdownMenuItem<DogBreed>(
                          value: breed,
                          child: Text(breed.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy ? null : onBreedChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DogAgeStage>(
                        initialValue: selectedAgeStage,
                        decoration: const InputDecoration(
                          labelText: '年齢感',
                          border: OutlineInputBorder(),
                        ),
                        items: DogAgeStage.values
                            .map(
                              (value) => DropdownMenuItem<DogAgeStage>(
                                value: value,
                                child: Text(value.labelJa),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: busy ? null : onAgeStageChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<DogSizeClass>(
                        initialValue: selectedSizeClass,
                        decoration: const InputDecoration(
                          labelText: 'サイズ感',
                          border: OutlineInputBorder(),
                        ),
                        items: DogSizeClass.values
                            .map(
                              (value) => DropdownMenuItem<DogSizeClass>(
                                value: value,
                                child: Text(value.labelJa),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: busy ? null : onSizeClassChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TensionLevel>(
                  initialValue: selectedTension,
                  decoration: const InputDecoration(
                    labelText: 'テンション',
                    border: OutlineInputBorder(),
                  ),
                  items: TensionLevel.values
                      .map(
                        (value) => DropdownMenuItem<TensionLevel>(
                          value: value,
                          child: Text(value.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy ? null : onTensionChanged,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '例: こっちに来て / Let us play together!',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: busy ? null : onTranslatePressed,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('犬っぽい声に変換して再生'),
                ),
                const SizedBox(height: 12),
                Text(statusMessage ?? '入力後に再生すると犬語っぽい音声を合成します。'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: result == null
                ? const Text('まだ逆変換結果がありません。')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result!.style.labelJa} / ${result!.breed.labelJa}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        result!.dogText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(result!.explanation),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
