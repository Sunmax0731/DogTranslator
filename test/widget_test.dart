import 'dart:typed_data';

import 'package:dog_translator/app/dog_translator_app.dart';
import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/inference_provider_factory.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings tab renders profile management and model selector', (
    tester,
  ) async {
    await tester.pumpWidget(
      DogTranslatorApp(
        recordingService: _FakeRecordingService(),
        playbackService: _FakePlaybackService(),
        repository: _InMemoryAppRepository(),
        inferenceProviderFactory: const InferenceProviderFactory.fixed(
          _FakeInferenceProvider(),
        ),
        initialTabIndex: 2,
      ),
    );
    await tester.pumpAndSettle();

    final settingsTargets = find.text('設定');
    if (settingsTargets.evaluate().isNotEmpty) {
      await tester.tap(settingsTargets.first);
      await tester.pumpAndSettle();
    }

    expect(find.text('カラーテーマ'), findsOneWidget);
    expect(find.text('推論モデル'), findsOneWidget);
  });
}

class _FakeRecordingService implements RecordingService {
  @override
  bool get isRecording => false;

  @override
  String? get selectedInputDeviceId => null;

  @override
  Stream<double> amplitudeStream() => const Stream<double>.empty();

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<List<RecordingInputDevice>> listInputDevices() async =>
      const <RecordingInputDevice>[
        RecordingInputDevice(id: 'mic-1', label: 'USB Microphone'),
      ];

  @override
  Future<void> selectInputDevice(String? deviceId) async {}

  @override
  Future<void> start() async {}

  @override
  Future<String?> stop() async => null;
}

class _FakePlaybackService implements BarkPlaybackService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> play(Uint8List wavBytes) async {}

  @override
  Future<void> playFile(String path) async {}
}

class _InMemoryAppRepository implements AppRepository {
  AppData data = AppData.empty;

  @override
  Future<AppData> load() async => data;

  @override
  Future<void> save(AppData newData) async {
    data = newData;
  }

  @override
  Future<String?> saveRecording(Uint8List wavBytes, String recordId) async =>
      'memory://$recordId.wav';
}

class _FakeInferenceProvider implements InferenceProvider {
  const _FakeInferenceProvider();

  @override
  Future<TranslationResult> analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
    Uint8List? wavBytes,
  }) async {
    return TranslationResult(
      intent: DogIntent.uncertain,
      explanation: 'test',
      confidence: ConfidenceLevel.low,
      features: features,
      candidates: const <TranslationCandidate>[],
      qualityIssues: const <RecordingQualityIssue>[],
      detectedDogVocal: false,
      vocalType: DogVocalType.unknown,
      context: DogContext.unknown,
      valence: 0,
      arousal: 0,
      rawConfidence: 0.1,
      providerLabel: 'fake',
    );
  }
}
