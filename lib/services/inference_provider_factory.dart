import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/services/local_inference_runtime.dart';
import 'package:dog_translator/services/local_process_inference_provider.dart';
import 'package:dog_translator/services/resilient_inference_provider.dart';

class InferenceProviderResolution {
  const InferenceProviderResolution({
    required this.provider,
    required this.requestedModel,
    required this.activeModel,
    required this.localRuntimeAvailable,
    required this.statusMessage,
  });

  final InferenceProvider provider;
  final InferenceModelSelection requestedModel;
  final InferenceModelSelection activeModel;
  final bool localRuntimeAvailable;
  final String statusMessage;
}

class InferenceProviderFactory {
  const InferenceProviderFactory({
    this.configLoader = const LocalInferenceRuntimeConfigLoader(),
  }) : _fixedProvider = null;

  const InferenceProviderFactory.fixed(InferenceProvider provider)
    : configLoader = const LocalInferenceRuntimeConfigLoader(),
      _fixedProvider = provider;

  final LocalInferenceRuntimeConfigLoader configLoader;
  final InferenceProvider? _fixedProvider;

  Future<InferenceProviderResolution> create({
    InferenceModelSelection selection = InferenceModelSelection.auto,
  }) async {
    final fixedProvider = _fixedProvider;
    if (fixedProvider != null) {
      return InferenceProviderResolution(
        provider: fixedProvider,
        requestedModel: selection,
        activeModel: selection == InferenceModelSelection.dog2vecLocal
            ? InferenceModelSelection.dog2vecLocal
            : InferenceModelSelection.heuristic,
        localRuntimeAvailable:
            selection == InferenceModelSelection.dog2vecLocal,
        statusMessage: '固定推論プロバイダを使用中です。',
      );
    }

    const heuristic = DogIntentInterpreter();
    final config = await configLoader.load();
    final localAvailable = config != null;

    switch (selection) {
      case InferenceModelSelection.heuristic:
        return const InferenceProviderResolution(
          provider: heuristic,
          requestedModel: InferenceModelSelection.heuristic,
          activeModel: InferenceModelSelection.heuristic,
          localRuntimeAvailable: false,
          statusMessage: '標準ヒューリスティック推論を使用します。',
        );
      case InferenceModelSelection.dog2vecLocal:
        if (config == null) {
          return const InferenceProviderResolution(
            provider: heuristic,
            requestedModel: InferenceModelSelection.dog2vecLocal,
            activeModel: InferenceModelSelection.heuristic,
            localRuntimeAvailable: false,
            statusMessage:
                'Dog2vec ローカル runtime が見つからないため、標準ヒューリスティック推論を使用します。',
          );
        }
        return InferenceProviderResolution(
          provider: ResilientInferenceProvider(
            primary: LocalProcessInferenceProvider(config: config),
            fallback: heuristic,
          ),
          requestedModel: InferenceModelSelection.dog2vecLocal,
          activeModel: InferenceModelSelection.dog2vecLocal,
          localRuntimeAvailable: true,
          statusMessage:
              'Dog2vec ローカル runtime を優先し、失敗時は標準ヒューリスティックへフォールバックします。',
        );
      case InferenceModelSelection.auto:
        if (config == null) {
          return const InferenceProviderResolution(
            provider: heuristic,
            requestedModel: InferenceModelSelection.auto,
            activeModel: InferenceModelSelection.heuristic,
            localRuntimeAvailable: false,
            statusMessage: 'Dog2vec ローカル runtime が未設定のため、標準ヒューリスティック推論を使用します。',
          );
        }
        return InferenceProviderResolution(
          provider: ResilientInferenceProvider(
            primary: LocalProcessInferenceProvider(config: config),
            fallback: heuristic,
          ),
          requestedModel: InferenceModelSelection.auto,
          activeModel: InferenceModelSelection.dog2vecLocal,
          localRuntimeAvailable: localAvailable,
          statusMessage: 'Dog2vec ローカル runtime を検出したため、自動的にそれを優先します。',
        );
    }
  }
}
