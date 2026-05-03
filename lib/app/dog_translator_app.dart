import 'package:dog_translator/features/home/dog_translator_home_page.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class DogTranslatorApp extends StatelessWidget {
  const DogTranslatorApp({
    required this.recordingService,
    required this.playbackService,
    this.initialTabIndex = 0,
    super.key,
  });

  final RecordingService recordingService;
  final BarkPlaybackService playbackService;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'DogTranslator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F1E8),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
      home: DogTranslatorHomePage(
        recordingService: recordingService,
        playbackService: playbackService,
        initialTabIndex: initialTabIndex,
      ),
    );
  }
}
