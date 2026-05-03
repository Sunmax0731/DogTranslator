import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/services/local_inference_runtime.dart';
import 'package:dog_translator/services/local_process_inference_provider.dart';
import 'package:dog_translator/services/resilient_inference_provider.dart';

class InferenceProviderFactory {
  const InferenceProviderFactory({
    this.configLoader = const LocalInferenceRuntimeConfigLoader(),
  });

  final LocalInferenceRuntimeConfigLoader configLoader;

  Future<InferenceProvider> create() async {
    const heuristic = DogIntentInterpreter();
    final config = await configLoader.load();
    if (config == null) {
      return heuristic;
    }

    return ResilientInferenceProvider(
      primary: LocalProcessInferenceProvider(config: config),
      fallback: heuristic,
    );
  }
}
