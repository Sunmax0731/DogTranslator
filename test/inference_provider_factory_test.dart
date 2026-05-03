import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/inference_provider_factory.dart';
import 'package:dog_translator/services/local_inference_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auto falls back to heuristic when no local runtime exists', () async {
    final factory = InferenceProviderFactory(
      configLoader: _FakeConfigLoader(null),
    );

    final resolution = await factory.create();

    expect(resolution.requestedModel, InferenceModelSelection.auto);
    expect(resolution.activeModel, InferenceModelSelection.heuristic);
    expect(resolution.localRuntimeAvailable, isFalse);
  });

  test('dog2vec local becomes active when runtime config exists', () async {
    final factory = InferenceProviderFactory(
      configLoader: _FakeConfigLoader(
        const LocalInferenceRuntimeConfig(
          enabled: true,
          command: 'python',
          arguments: <String>['infer.py'],
          timeout: Duration(seconds: 5),
        ),
      ),
    );

    final resolution = await factory.create(
      selection: InferenceModelSelection.dog2vecLocal,
    );

    expect(resolution.requestedModel, InferenceModelSelection.dog2vecLocal);
    expect(resolution.activeModel, InferenceModelSelection.dog2vecLocal);
    expect(resolution.localRuntimeAvailable, isTrue);
  });
}

class _FakeConfigLoader extends LocalInferenceRuntimeConfigLoader {
  const _FakeConfigLoader(this.config);

  final LocalInferenceRuntimeConfig? config;

  @override
  Future<LocalInferenceRuntimeConfig?> load() async => config;
}
