import 'package:dog_translator/app/dog_translator_app.dart';
import 'package:dog_translator/services/audio_player_bark_playback_service.dart';
import 'package:dog_translator/services/json_file_app_repository.dart';
import 'package:dog_translator/services/record_recording_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    DogTranslatorApp(
      recordingService: RecordRecordingService(),
      playbackService: AudioPlayerBarkPlaybackService(),
      repository: JsonFileAppRepository(),
    ),
  );
}
