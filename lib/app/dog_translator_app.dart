import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/features/home/dog_translator_home_page.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/inference_provider_factory.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class DogTranslatorApp extends StatefulWidget {
  const DogTranslatorApp({
    required this.recordingService,
    required this.playbackService,
    required this.repository,
    required this.inferenceProviderFactory,
    this.initialTabIndex = 0,
    super.key,
  });

  final RecordingService recordingService;
  final BarkPlaybackService playbackService;
  final AppRepository repository;
  final InferenceProviderFactory inferenceProviderFactory;
  final int initialTabIndex;

  @override
  State<DogTranslatorApp> createState() => _DogTranslatorAppState();
}

class _DogTranslatorAppState extends State<DogTranslatorApp> {
  AppThemePreset _themePreset = AppThemePreset.defaultTeal;

  @override
  Widget build(BuildContext context) {
    final theme = _buildTheme(_themePreset);

    return MaterialApp(
      title: 'DogTranslator',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: DogTranslatorHomePage(
        recordingService: widget.recordingService,
        playbackService: widget.playbackService,
        repository: widget.repository,
        inferenceProviderFactory: widget.inferenceProviderFactory,
        initialTabIndex: widget.initialTabIndex,
        onThemePresetChanged: (preset) {
          if (_themePreset == preset) {
            return;
          }
          setState(() {
            _themePreset = preset;
          });
        },
      ),
    );
  }

  ThemeData _buildTheme(AppThemePreset preset) {
    final seed = switch (preset) {
      AppThemePreset.defaultTeal => const Color(0xFF0F766E),
      AppThemePreset.ocean => const Color(0xFF2563EB),
      AppThemePreset.sunset => const Color(0xFFE67E22),
      AppThemePreset.forest => const Color(0xFF2E7D32),
      AppThemePreset.graphite => const Color(0xFF4B5563),
      AppThemePreset.darkMode => const Color(0xFF60A5FA),
    };
    final isDark = preset == AppThemePreset.darkMode;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF5F6F8),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF111827) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
