import 'dart:typed_data';

abstract class BarkPlaybackService {
  Future<void> play(Uint8List wavBytes);

  Future<void> dispose();
}
