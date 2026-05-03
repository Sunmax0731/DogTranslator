import 'dart:typed_data';

import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';

class ResilientInferenceProvider implements InferenceProvider {
  const ResilientInferenceProvider({
    required InferenceProvider primary,
    required InferenceProvider fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final InferenceProvider _primary;
  final InferenceProvider _fallback;

  @override
  Future<TranslationResult> analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
    Uint8List? wavBytes,
  }) async {
    try {
      return await _primary.analyze(
        features,
        profile: profile,
        sceneMode: sceneMode,
        wavBytes: wavBytes,
      );
    } catch (_) {
      return _fallback.analyze(
        features,
        profile: profile,
        sceneMode: sceneMode,
        wavBytes: wavBytes,
      );
    }
  }
}
