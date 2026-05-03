import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dog_translator/services/bark_playback_service.dart';

class AudioPlayerBarkPlaybackService implements BarkPlaybackService {
  AudioPlayerBarkPlaybackService() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> play(Uint8List wavBytes) async {
    final file = File(
      '${Directory.systemTemp.path}\\dog_translator_bark_${DateTime.now().microsecondsSinceEpoch}.wav',
    );
    await file.writeAsBytes(wavBytes, flush: true);
    await _player.stop();
    await _player.play(DeviceFileSource(file.path));
  }

  @override
  Future<void> dispose() {
    return _player.dispose();
  }
}
