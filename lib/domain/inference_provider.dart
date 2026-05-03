import 'dart:typed_data';

import 'package:dog_translator/domain/models.dart';

abstract class InferenceProvider {
  Future<TranslationResult> analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
    Uint8List? wavBytes,
  });
}
