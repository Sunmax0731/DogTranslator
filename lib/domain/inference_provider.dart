import 'package:dog_translator/domain/models.dart';

abstract class InferenceProvider {
  TranslationResult analyze(
    AudioFeatures features, {
    DogProfile? profile,
    SceneMode sceneMode = SceneMode.home,
  });
}
