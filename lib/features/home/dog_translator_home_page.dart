import 'dart:async';

import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/features/home/home_controller.dart';
import 'package:dog_translator/features/home/widgets/dashboard_tab.dart';
import 'package:dog_translator/features/home/widgets/forward_translator_tab.dart';
import 'package:dog_translator/features/home/widgets/history_panel.dart';
import 'package:dog_translator/features/home/widgets/reverse_translator_tab.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class DogTranslatorHomePage extends StatefulWidget {
  const DogTranslatorHomePage({
    required this.recordingService,
    required this.playbackService,
    required this.repository,
    required this.inferenceProvider,
    this.initialTabIndex = 0,
    super.key,
  });

  final RecordingService recordingService;
  final BarkPlaybackService playbackService;
  final AppRepository repository;
  final InferenceProvider inferenceProvider;
  final int initialTabIndex;

  @override
  State<DogTranslatorHomePage> createState() => _DogTranslatorHomePageState();
}

class _DogTranslatorHomePageState extends State<DogTranslatorHomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      recordingService: widget.recordingService,
      playbackService: widget.playbackService,
      repository: widget.repository,
      inferenceProvider: widget.inferenceProvider,
    );
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final historyPanel = HistoryPanel(
                forwardRecords: _controller.forwardRecords,
                reverseRecords: _controller.reverseRecords,
                compareSelection: _controller.comparisonSelection,
                onToggleCompare: _controller.toggleCompareSelection,
              );

              final mainContent = Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0F766E),
                          Color(0xFF115E59),
                          Color(0xFF134E4A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DogTranslator',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '犬語の「翻訳」ではなく、鳴き声の傾向から感情や意図を推定する Windows アプリです。',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const TabBar(
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18),
                                ),
                              ),
                              labelColor: Color(0xFF134E4A),
                              unselectedLabelColor: Colors.white,
                              tabs: [
                                Tab(text: '犬の声 -> 人の言葉'),
                                Tab(text: '人の言葉 -> 犬っぽい声'),
                                Tab(text: 'Dashboard'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _controller.loadingAppData
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.all(20),
                            child: TabBarView(
                              children: [
                                ForwardTranslatorTab(
                                  result: _controller.translationResult,
                                  latestRecord: _controller.latestForwardRecord,
                                  isRecording: _controller.isRecording,
                                  busy: _controller.recordingBusy,
                                  loadingInputDevices:
                                      _controller.loadingInputDevices,
                                  statusMessage:
                                      _controller.forwardStatusMessage,
                                  waveformSamples: _controller.waveformSamples,
                                  inputDevices: _controller.inputDevices,
                                  selectedInputDeviceId:
                                      _controller.selectedInputDeviceId,
                                  profiles: _controller.profiles,
                                  selectedProfileId:
                                      _controller.selectedProfileId,
                                  selectedSceneMode:
                                      _controller.selectedSceneMode,
                                  onProfileChanged: _controller.selectProfile,
                                  onCreateProfilePressed: () =>
                                      _controller.createProfile(context),
                                  onSceneModeChanged: _controller.setSceneMode,
                                  onInputDeviceSelected:
                                      _controller.selectInputDevice,
                                  onRefreshInputDevices:
                                      _controller.loadInputDevices,
                                  onRecordPressed: _controller.toggleRecording,
                                  onFeedbackChanged: _controller.applyFeedback,
                                ),
                                ReverseTranslatorTab(
                                  controller: _controller.reverseTextController,
                                  result: _controller.reverseResult,
                                  busy: _controller.reverseBusy,
                                  profiles: _controller.profiles,
                                  selectedProfileId:
                                      _controller.selectedProfileId,
                                  selectedBreed: _controller.selectedBreed,
                                  selectedAgeStage:
                                      _controller.selectedAgeStage,
                                  selectedSizeClass:
                                      _controller.selectedSizeClass,
                                  selectedTension: _controller.selectedTension,
                                  selectedSceneMode:
                                      _controller.selectedSceneMode,
                                  statusMessage:
                                      _controller.reverseStatusMessage,
                                  onProfileChanged: _controller.selectProfile,
                                  onSceneModeChanged: _controller.setSceneMode,
                                  onBreedChanged: _controller.setBreed,
                                  onAgeStageChanged: _controller.setAgeStage,
                                  onSizeClassChanged: _controller.setSizeClass,
                                  onTensionChanged: _controller.setTension,
                                  onTranslatePressed:
                                      _controller.runReverseTranslation,
                                ),
                                DashboardTab(
                                  analyticsSummary:
                                      _controller.analyticsSummary,
                                  comparisonRecords:
                                      _controller.comparisonRecords,
                                  profiles: _controller.profiles,
                                  forwardRecords: _controller.forwardRecords,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              );

              if (constraints.maxWidth > 1180) {
                return Scaffold(
                  body: Row(
                    children: [
                      Expanded(flex: 3, child: mainContent),
                      SizedBox(
                        width: 360,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                          child: historyPanel,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Scaffold(
                body: Column(
                  children: [
                    Expanded(child: mainContent),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(height: 260, child: historyPanel),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
