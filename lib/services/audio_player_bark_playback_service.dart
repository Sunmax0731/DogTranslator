import 'dart:async';
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

    await playFile(file.path);
  }

  @override
  Future<void> playFile(String path) async {
    if (Platform.isWindows) {
      await _playWithWindowsSoundPlayer(path);
      return;
    }

    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  @override
  Future<void> dispose() {
    return _player.dispose();
  }

  Future<void> _playWithWindowsSoundPlayer(String path) async {
    final escapedPath = path.replaceAll("'", "''");
    final command =
        "\$player = New-Object System.Media.SoundPlayer('$escapedPath'); "
        '\$player.Load(); '
        '\$player.PlaySync();';

    final process = await Process.start('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-WindowStyle',
      'Hidden',
      '-Command',
      command,
    ], runInShell: false);

    unawaited(process.exitCode);
  }
}
