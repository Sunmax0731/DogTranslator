import 'package:dog_translator/app/dog_translator_app.dart';
import 'package:dog_translator/services/inference_provider_factory.dart';
import 'package:dog_translator/services/audio_player_bark_playback_service.dart';
import 'package:dog_translator/services/json_file_app_repository.dart';
import 'package:dog_translator/services/record_recording_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final inferenceProvider = await const InferenceProviderFactory().create();
  runApp(
    DogTranslatorApp(
      recordingService: RecordRecordingService(),
      playbackService: AudioPlayerBarkPlaybackService(),
      repository: JsonFileAppRepository(),
      inferenceProvider: inferenceProvider,
    ),
  );
}
