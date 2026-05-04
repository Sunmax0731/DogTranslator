import 'dart:async';

import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/features/home/home_controller.dart';
import 'package:dog_translator/features/home/widgets/dashboard_tab.dart';
import 'package:dog_translator/features/home/widgets/forward_translator_tab.dart';
import 'package:dog_translator/features/home/widgets/history_panel.dart';
import 'package:dog_translator/features/home/widgets/settings_tab.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/inference_provider_factory.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class DogTranslatorHomePage extends StatefulWidget {
  const DogTranslatorHomePage({
    required this.recordingService,
    required this.playbackService,
    required this.repository,
    required this.inferenceProviderFactory,
    required this.onThemePresetChanged,
    this.initialTabIndex = 0,
    super.key,
  });

  final RecordingService recordingService;
  final BarkPlaybackService playbackService;
  final AppRepository repository;
  final InferenceProviderFactory inferenceProviderFactory;
  final ValueChanged<AppThemePreset> onThemePresetChanged;
  final int initialTabIndex;

  @override
  State<DogTranslatorHomePage> createState() => _DogTranslatorHomePageState();
}

class _DogTranslatorHomePageState extends State<DogTranslatorHomePage> {
  late final HomeController _controller;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, 2);
    _controller = HomeController(
      recordingService: widget.recordingService,
      playbackService: widget.playbackService,
      repository: widget.repository,
      inferenceProviderFactory: widget.inferenceProviderFactory,
      onThemePresetChanged: widget.onThemePresetChanged,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final pages = [
              ForwardTranslatorTab(
                result: _controller.translationResult,
                latestRecord: _controller.latestForwardRecord,
                isRecording: _controller.isRecording,
                busy: _controller.recordingBusy,
                analysisInProgress: _controller.analysisInProgress,
                analysisProgress: _controller.analysisProgress,
                analysisStageMessage: _controller.analysisStageMessage,
                loadingInputDevices: _controller.loadingInputDevices,
                statusMessage: _controller.forwardStatusMessage,
                waveformSamples: _controller.waveformSamples,
                inputDevices: _controller.inputDevices,
                selectedInputDeviceId: _controller.selectedInputDeviceId,
                profiles: _controller.profiles,
                selectedProfileId: _controller.selectedProfileId,
                selectedSceneMode: _controller.selectedSceneMode,
                onProfileChanged: _controller.selectProfile,
                onCreateProfilePressed: () =>
                    _controller.createProfile(context),
                onSceneModeChanged: _controller.setSceneMode,
                onInputDeviceSelected: _controller.selectInputDevice,
                onRefreshInputDevices: _controller.loadInputDevices,
                onRecordPressed: _controller.toggleRecording,
                onFeedbackChanged: _controller.applyFeedback,
              ),
              DashboardTab(
                analyticsSummary: _controller.analyticsSummary,
                comparisonRecords: _controller.comparisonRecords,
                profiles: _controller.profiles,
                forwardRecords: _controller.forwardRecords,
              ),
              SettingsTab(
                selectedThemePreset: _controller.selectedThemePreset,
                selectedInferenceModel: _controller.selectedInferenceModel,
                inferenceStatusMessage: _controller.inferenceStatusMessage,
                profiles: _controller.profiles,
                latestForwardRecord: _controller.latestForwardRecord,
                onThemeChanged: _controller.setThemePreset,
                onInferenceModelChanged: _controller.setInferenceModel,
                onCreateProfilePressed: () =>
                    _controller.createProfile(context),
                onEditProfilePressed: (profile) =>
                    _controller.editProfile(context, profile),
                onDeleteProfilePressed: _controller.deleteProfile,
                onAddCalibrationSamplePressed:
                    _controller.addLatestRecordingToProfileCalibration,
              ),
            ];

            final profileNameById = <String, String>{
              for (final profile in _controller.profiles)
                profile.id: profile.name,
            };

            final content = _controller.loadingAppData
                ? const Center(child: CircularProgressIndicator())
                : pages[_selectedIndex];

            final historyPanel = HistoryPanel(
              forwardRecords: _controller.forwardRecords,
              profileNameById: profileNameById,
              compareSelection: _controller.comparisonSelection,
              onToggleCompare: _controller.toggleCompareSelection,
              onPlayForwardRecord: _controller.playForwardRecord,
            );

            if (constraints.maxWidth > 1180) {
              return Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: _NavigationPane(
                            selectedIndex: _selectedIndex,
                            onSelected: _setSelectedIndex,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _PageHeader(
                                title: _pageTitle(_selectedIndex),
                                subtitle: _pageSubtitle(_selectedIndex),
                              ),
                              const SizedBox(height: 16),
                              Expanded(child: content),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(width: 380, child: historyPanel),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(_pageTitle(_selectedIndex)),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Expanded(child: content),
                    const SizedBox(height: 16),
                    SizedBox(height: 300, child: historyPanel),
                  ],
                ),
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _setSelectedIndex,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.mic_none_outlined),
                    selectedIcon: Icon(Icons.mic),
                    label: '解析',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: '分析',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: '設定',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _pageTitle(int index) {
    return switch (index) {
      0 => 'DogTranslator',
      1 => 'Dashboard',
      _ => 'Settings',
    };
  }

  String _pageSubtitle(int index) {
    return switch (index) {
      0 => '録音した犬の鳴き声を解析します。',
      1 => '履歴と推論傾向を確認します。',
      _ => 'アプリ全体の設定とプロフィールを管理します。',
    };
  }
}

class _NavigationPane extends StatelessWidget {
  const _NavigationPane({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'DogTranslator',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            _NavButton(
              selected: selectedIndex == 0,
              icon: Icons.mic,
              label: '解析',
              onTap: () => onSelected(0),
            ),
            _NavButton(
              selected: selectedIndex == 1,
              icon: Icons.insights,
              label: '分析',
              onTap: () => onSelected(1),
            ),
            _NavButton(
              selected: selectedIndex == 2,
              icon: Icons.settings,
              label: '設定',
              onTap: () => onSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [Icon(icon), const SizedBox(width: 12), Text(label)],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
