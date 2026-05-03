import 'dart:async';
import 'dart:io';

import 'package:dog_translator/domain/analytics_service.dart';
import 'package:dog_translator/domain/audio_feature_extractor.dart';
import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/domain/reverse_translator.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class DogTranslatorHomePage extends StatefulWidget {
  const DogTranslatorHomePage({
    required this.recordingService,
    required this.playbackService,
    required this.repository,
    this.initialTabIndex = 0,
    super.key,
  });

  final RecordingService recordingService;
  final BarkPlaybackService playbackService;
  final AppRepository repository;
  final int initialTabIndex;

  @override
  State<DogTranslatorHomePage> createState() => _DogTranslatorHomePageState();
}

class _DogTranslatorHomePageState extends State<DogTranslatorHomePage> {
  final AudioFeatureExtractor _featureExtractor = const AudioFeatureExtractor();
  final DogIntentInterpreter _inferenceProvider = const DogIntentInterpreter();
  final ReverseTranslator _reverseTranslator = ReverseTranslator();
  final AnalyticsService _analyticsService = const AnalyticsService();
  final TextEditingController _textController = TextEditingController();
  final List<double> _waveformSamples = <double>[];
  final Set<String> _comparisonSelection = <String>{};

  StreamSubscription<double>? _amplitudeSubscription;

  TranslationResult? _translationResult;
  ReverseTranslationResult? _reverseResult;
  String? _latestForwardRecordId;
  List<RecordingInputDevice> _inputDevices = const <RecordingInputDevice>[];
  List<DogProfile> _profiles = const <DogProfile>[];
  List<ForwardRecord> _forwardRecords = const <ForwardRecord>[];
  List<ReverseRecord> _reverseRecords = const <ReverseRecord>[];
  String? _selectedInputDeviceId;
  String? _selectedProfileId;
  DogBreed _selectedBreed = DogBreed.mixed;
  DogAgeStage _selectedAgeStage = DogAgeStage.adult;
  DogSizeClass _selectedSizeClass = DogSizeClass.medium;
  TensionLevel _selectedTension = TensionLevel.normal;
  SceneMode _selectedSceneMode = SceneMode.home;
  bool _recordingBusy = false;
  bool _reverseBusy = false;
  bool _loadingInputDevices = true;
  bool _loadingAppData = true;
  String? _forwardStatusMessage;
  String? _reverseStatusMessage;

  DogProfile? get _selectedProfile {
    for (final profile in _profiles) {
      if (profile.id == _selectedProfileId) {
        return profile;
      }
    }
    return null;
  }

  AnalyticsSummary get _analyticsSummary =>
      _analyticsService.summarize(_forwardRecords, _reverseRecords, _profiles);

  List<ForwardRecord> get _comparisonRecords {
    final records = _forwardRecords
        .where((record) => _comparisonSelection.contains(record.id))
        .toList(growable: false);
    records.sort((a, b) => b.timestampIso.compareTo(a.timestampIso));
    return records.take(2).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _selectedInputDeviceId = widget.recordingService.selectedInputDeviceId;
    unawaited(_initializeApp());
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _textController.dispose();
    widget.recordingService.dispose();
    widget.playbackService.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.wait([_loadAppData(), _loadInputDevices()]);
  }

  Future<void> _loadAppData() async {
    final data = await widget.repository.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _profiles = data.profiles;
      _forwardRecords = data.forwardRecords;
      _reverseRecords = data.reverseRecords;
      _selectedProfileId = data.settings.selectedProfileId;
      _selectedInputDeviceId =
          data.settings.selectedInputDeviceId ?? _selectedInputDeviceId;
      _selectedBreed = data.settings.selectedBreed;
      _selectedAgeStage = data.settings.selectedAgeStage;
      _selectedSizeClass = data.settings.selectedSizeClass;
      _selectedTension = data.settings.selectedTension;
      _selectedSceneMode = data.settings.selectedSceneMode;
      _loadingAppData = false;
    });
  }

  Future<void> _persistState() {
    return widget.repository.save(
      AppData(
        profiles: _profiles,
        forwardRecords: _forwardRecords,
        reverseRecords: _reverseRecords,
        settings: AppSettings(
          selectedProfileId: _selectedProfileId,
          selectedInputDeviceId: _selectedInputDeviceId,
          selectedBreed: _selectedBreed,
          selectedAgeStage: _selectedAgeStage,
          selectedSizeClass: _selectedSizeClass,
          selectedTension: _selectedTension,
          selectedSceneMode: _selectedSceneMode,
        ),
      ),
    );
  }

  Future<void> _loadInputDevices() async {
    setState(() {
      _loadingInputDevices = true;
    });

    try {
      final devices = await widget.recordingService.listInputDevices();
      if (!mounted) {
        return;
      }
      setState(() {
        _inputDevices = devices;
        final currentId = _selectedInputDeviceId;
        if (currentId != null &&
            devices.every((device) => device.id != currentId)) {
          _selectedInputDeviceId = null;
          _forwardStatusMessage = '選択したマイクが見つからなかったため、既定の入力に戻しました。';
        }
      });
      await _persistState();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _forwardStatusMessage = '入力マイク一覧の取得に失敗しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingInputDevices = false;
        });
      }
    }
  }

  Future<void> _selectInputDevice(String? deviceId) async {
    if (_recordingBusy || widget.recordingService.isRecording) {
      return;
    }

    await widget.recordingService.selectInputDevice(deviceId);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedInputDeviceId = deviceId;
      _forwardStatusMessage = deviceId == null
          ? '既定のマイクを使う設定にしました。'
          : '入力マイクを切り替えました。';
    });
    await _persistState();
  }

  Future<void> _toggleRecording() async {
    if (_recordingBusy) {
      return;
    }

    setState(() {
      _recordingBusy = true;
      _forwardStatusMessage = null;
    });

    try {
      if (widget.recordingService.isRecording) {
        await _amplitudeSubscription?.cancel();
        _amplitudeSubscription = null;

        final path = await widget.recordingService.stop();
        if (path == null || !await File(path).exists()) {
          setState(() {
            _forwardStatusMessage = '録音ファイルを取得できませんでした。';
          });
          return;
        }

        final bytes = await File(path).readAsBytes();
        final features = _featureExtractor.extractFromWavBytes(bytes);
        final result = _inferenceProvider.analyze(
          features,
          profile: _selectedProfile,
          sceneMode: _selectedSceneMode,
        );
        final recordId = _createId('fwd');
        final recordingPath = await widget.repository.saveRecording(
          bytes,
          recordId,
        );
        final record = ForwardRecord(
          id: recordId,
          timestampIso: DateTime.now().toIso8601String(),
          profileId: _selectedProfileId,
          sceneMode: _selectedSceneMode,
          translation: result,
          recordingPath: recordingPath,
          feedbackLabel: null,
        );

        setState(() {
          _translationResult = result;
          _latestForwardRecordId = recordId;
          _forwardRecords = <ForwardRecord>[record, ..._forwardRecords];
          _forwardStatusMessage = '録音を解析して保存しました。';
        });
        await _persistState();
      } else {
        final hasPermission = await widget.recordingService.hasPermission();
        if (!hasPermission) {
          setState(() {
            _forwardStatusMessage = 'マイクへのアクセスが許可されていません。';
          });
          return;
        }

        await widget.recordingService.selectInputDevice(_selectedInputDeviceId);
        await widget.recordingService.start();
        _beginWaveformSampling();

        setState(() {
          _waveformSamples
            ..clear()
            ..addAll(List<double>.filled(48, 0));
          _forwardStatusMessage = '録音中です。もう一度押すと解析して保存します。';
        });
      }
    } on FormatException catch (error) {
      setState(() {
        _forwardStatusMessage = '録音解析に失敗しました: ${error.message}';
      });
    } catch (error) {
      setState(() {
        _forwardStatusMessage = '録音処理でエラーが発生しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _recordingBusy = false;
        });
      }
    }
  }

  void _beginWaveformSampling() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = widget.recordingService.amplitudeStream().listen((
      value,
    ) {
      if (!mounted || !widget.recordingService.isRecording) {
        return;
      }
      setState(() {
        if (_waveformSamples.length >= 48) {
          _waveformSamples.removeAt(0);
        }
        _waveformSamples.add(value.clamp(0.0, 1.0));
      });
    });
  }

  Future<void> _runReverseTranslation() async {
    if (_reverseBusy) {
      return;
    }

    setState(() {
      _reverseBusy = true;
      _reverseStatusMessage = null;
    });

    try {
      final result = _reverseTranslator.translate(
        _textController.text,
        breed: _selectedBreed,
        ageStage: _selectedAgeStage,
        sizeClass: _selectedSizeClass,
        tension: _selectedTension,
      );
      final record = ReverseRecord(
        id: _createId('rev'),
        timestampIso: DateTime.now().toIso8601String(),
        profileId: _selectedProfileId,
        sceneMode: _selectedSceneMode,
        style: result.style,
        breed: result.breed,
        ageStage: result.ageStage,
        sizeClass: result.sizeClass,
        tension: result.tension,
        dogText: result.dogText,
        explanation: result.explanation,
      );

      setState(() {
        _reverseResult = result;
        _reverseRecords = <ReverseRecord>[record, ..._reverseRecords];
        _reverseStatusMessage = '犬っぽい結果を生成して保存しました。音声再生を試します。';
      });
      await _persistState();

      unawaited(_playReverseAudio(result));
    } catch (error) {
      setState(() {
        _reverseStatusMessage = '逆変換の生成でエラーが発生しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _reverseBusy = false;
        });
      }
    }
  }

  Future<void> _playReverseAudio(ReverseTranslationResult result) async {
    try {
      await widget.playbackService.play(result.audioBytes);
      if (!mounted) {
        return;
      }
      setState(() {
        _reverseStatusMessage = '犬っぽい音声を再生しました。';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reverseStatusMessage = '結果は生成しましたが、音声再生に失敗しました: $error';
      });
    }
  }

  Future<void> _applyFeedback(UserFeedbackLabel? label) async {
    final recordId = _latestForwardRecordId;
    if (recordId == null || label == null) {
      return;
    }

    final updated = _forwardRecords
        .map((record) {
          if (record.id != recordId) {
            return record;
          }
          return ForwardRecord(
            id: record.id,
            timestampIso: record.timestampIso,
            profileId: record.profileId,
            sceneMode: record.sceneMode,
            translation: record.translation,
            recordingPath: record.recordingPath,
            feedbackLabel: label,
          );
        })
        .toList(growable: false);

    setState(() {
      _forwardRecords = updated;
    });
    await _persistState();
  }

  Future<void> _createProfile() async {
    final created = await showDialog<DogProfile>(
      context: context,
      builder: (context) => const _CreateProfileDialog(),
    );
    if (created == null) {
      return;
    }

    setState(() {
      _profiles = <DogProfile>[created, ..._profiles];
      _selectedProfileId = created.id;
      _selectedBreed = created.breed;
      _selectedAgeStage = created.ageStage;
      _selectedSizeClass = created.sizeClass;
      _forwardStatusMessage = 'プロフィールを追加しました。';
    });
    await _persistState();
  }

  Future<void> _selectProfile(String? profileId) async {
    setState(() {
      _selectedProfileId = profileId;
    });
    final profile = _selectedProfile;
    if (profile != null) {
      setState(() {
        _selectedBreed = profile.breed;
        _selectedAgeStage = profile.ageStage;
        _selectedSizeClass = profile.sizeClass;
      });
    }
    await _persistState();
  }

  Future<void> _setSceneMode(SceneMode? mode) async {
    if (mode == null) {
      return;
    }
    setState(() {
      _selectedSceneMode = mode;
    });
    await _persistState();
  }

  Future<void> _setBreed(DogBreed? breed) async {
    if (breed == null) {
      return;
    }
    setState(() {
      _selectedBreed = breed;
    });
    await _persistState();
  }

  Future<void> _setAgeStage(DogAgeStage? ageStage) async {
    if (ageStage == null) {
      return;
    }
    setState(() {
      _selectedAgeStage = ageStage;
    });
    await _persistState();
  }

  Future<void> _setSizeClass(DogSizeClass? sizeClass) async {
    if (sizeClass == null) {
      return;
    }
    setState(() {
      _selectedSizeClass = sizeClass;
    });
    await _persistState();
  }

  Future<void> _setTension(TensionLevel? tension) async {
    if (tension == null) {
      return;
    }
    setState(() {
      _selectedTension = tension;
    });
    await _persistState();
  }

  void _toggleCompareSelection(String id) {
    setState(() {
      if (_comparisonSelection.contains(id)) {
        _comparisonSelection.remove(id);
        return;
      }
      if (_comparisonSelection.length >= 2) {
        final first = _comparisonSelection.first;
        _comparisonSelection.remove(first);
      }
      _comparisonSelection.add(id);
    });
  }

  String _createId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final historyPanel = _HistoryPanel(
            profiles: _profiles,
            forwardRecords: _forwardRecords,
            reverseRecords: _reverseRecords,
            compareSelection: _comparisonSelection,
            onToggleCompare: _toggleCompareSelection,
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
                            borderRadius: BorderRadius.all(Radius.circular(18)),
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
                child: _loadingAppData
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: TabBarView(
                          children: [
                            _ForwardTranslatorTab(
                              result: _translationResult,
                              latestRecord: _latestForwardRecordId == null
                                  ? null
                                  : _findForwardRecord(_latestForwardRecordId!),
                              isRecording: widget.recordingService.isRecording,
                              busy: _recordingBusy,
                              loadingInputDevices: _loadingInputDevices,
                              statusMessage: _forwardStatusMessage,
                              waveformSamples: _waveformSamples,
                              inputDevices: _inputDevices,
                              selectedInputDeviceId: _selectedInputDeviceId,
                              profiles: _profiles,
                              selectedProfileId: _selectedProfileId,
                              selectedSceneMode: _selectedSceneMode,
                              onProfileChanged: _selectProfile,
                              onCreateProfilePressed: _createProfile,
                              onSceneModeChanged: _setSceneMode,
                              onInputDeviceSelected: _selectInputDevice,
                              onRefreshInputDevices: _loadInputDevices,
                              onRecordPressed: _toggleRecording,
                              onFeedbackChanged: _applyFeedback,
                            ),
                            _ReverseTranslatorTab(
                              controller: _textController,
                              result: _reverseResult,
                              busy: _reverseBusy,
                              profiles: _profiles,
                              selectedProfileId: _selectedProfileId,
                              selectedBreed: _selectedBreed,
                              selectedAgeStage: _selectedAgeStage,
                              selectedSizeClass: _selectedSizeClass,
                              selectedTension: _selectedTension,
                              selectedSceneMode: _selectedSceneMode,
                              statusMessage: _reverseStatusMessage,
                              onProfileChanged: _selectProfile,
                              onSceneModeChanged: _setSceneMode,
                              onBreedChanged: _setBreed,
                              onAgeStageChanged: _setAgeStage,
                              onSizeClassChanged: _setSizeClass,
                              onTensionChanged: _setTension,
                              onTranslatePressed: _runReverseTranslation,
                            ),
                            _DashboardTab(
                              analyticsSummary: _analyticsSummary,
                              comparisonRecords: _comparisonRecords,
                              profiles: _profiles,
                              forwardRecords: _forwardRecords,
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
      ),
    );
  }

  ForwardRecord? _findForwardRecord(String id) {
    for (final record in _forwardRecords) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }
}

class _ForwardTranslatorTab extends StatelessWidget {
  const _ForwardTranslatorTab({
    required this.result,
    required this.latestRecord,
    required this.isRecording,
    required this.busy,
    required this.loadingInputDevices,
    required this.statusMessage,
    required this.waveformSamples,
    required this.inputDevices,
    required this.selectedInputDeviceId,
    required this.profiles,
    required this.selectedProfileId,
    required this.selectedSceneMode,
    required this.onProfileChanged,
    required this.onCreateProfilePressed,
    required this.onSceneModeChanged,
    required this.onInputDeviceSelected,
    required this.onRefreshInputDevices,
    required this.onRecordPressed,
    required this.onFeedbackChanged,
  });

  final TranslationResult? result;
  final ForwardRecord? latestRecord;
  final bool isRecording;
  final bool busy;
  final bool loadingInputDevices;
  final String? statusMessage;
  final List<double> waveformSamples;
  final List<RecordingInputDevice> inputDevices;
  final String? selectedInputDeviceId;
  final List<DogProfile> profiles;
  final String? selectedProfileId;
  final SceneMode selectedSceneMode;
  final ValueChanged<String?> onProfileChanged;
  final VoidCallback onCreateProfilePressed;
  final ValueChanged<SceneMode?> onSceneModeChanged;
  final ValueChanged<String?> onInputDeviceSelected;
  final VoidCallback onRefreshInputDevices;
  final VoidCallback onRecordPressed;
  final ValueChanged<UserFeedbackLabel?> onFeedbackChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forward Interpretation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('録音した犬の鳴き声から、感情や意図を日本語で推定します。'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedProfileId,
                        decoration: const InputDecoration(
                          labelText: '犬プロフィール',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('プロフィール未選択'),
                          ),
                          ...profiles.map(
                            (profile) => DropdownMenuItem<String?>(
                              value: profile.id,
                              child: Text(profile.name),
                            ),
                          ),
                        ],
                        onChanged: busy || isRecording
                            ? null
                            : onProfileChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: busy || isRecording
                          ? null
                          : onCreateProfilePressed,
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SceneMode>(
                  initialValue: selectedSceneMode,
                  decoration: const InputDecoration(
                    labelText: 'シーン',
                    border: OutlineInputBorder(),
                  ),
                  items: SceneMode.values
                      .map(
                        (mode) => DropdownMenuItem<SceneMode>(
                          value: mode,
                          child: Text(mode.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy || isRecording ? null : onSceneModeChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: selectedInputDeviceId,
                        decoration: const InputDecoration(
                          labelText: '入力マイク',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('既定のマイク'),
                          ),
                          ...inputDevices.map(
                            (device) => DropdownMenuItem<String?>(
                              value: device.id,
                              child: Text(device.label),
                            ),
                          ),
                        ],
                        onChanged: loadingInputDevices || busy || isRecording
                            ? null
                            : onInputDeviceSelected,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'マイク一覧を更新',
                      onPressed: loadingInputDevices || busy || isRecording
                          ? null
                          : onRefreshInputDevices,
                      icon: loadingInputDevices
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WaveformPanel(
                  isRecording: isRecording,
                  waveformSamples: waveformSamples,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy ? null : onRecordPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: isRecording
                        ? const Color(0xFFB91C1C)
                        : colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                  icon: Icon(isRecording ? Icons.stop_circle : Icons.mic),
                  label: Text(isRecording ? '録音を止めて解析' : '録音を開始'),
                ),
                const SizedBox(height: 12),
                Text(
                  statusMessage ?? 'マイクボタンを押して録音を始めてください。',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: result == null
                ? const Text('まだ解析結果がありません。録音後にここへ結果を表示します。')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result!.intent.labelJa,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(result!.explanation),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FeatureChip(
                            label: '確信度',
                            value: result!.confidence.labelJa,
                          ),
                          _FeatureChip(
                            label: '録音長',
                            value:
                                '${result!.features.durationSeconds.toStringAsFixed(2)}s',
                          ),
                          _FeatureChip(
                            label: 'RMS',
                            value: result!.features.rms.toStringAsFixed(3),
                          ),
                          _FeatureChip(
                            label: 'Peak',
                            value: result!.features.peak.toStringAsFixed(3),
                          ),
                          _FeatureChip(
                            label: 'Burst',
                            value: result!.features.burstCount.toString(),
                          ),
                          _FeatureChip(
                            label: 'Spectral',
                            value: result!.features.spectralCentroid
                                .toStringAsFixed(0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '候補',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...result!.candidates.map(
                        (candidate) => Text(
                          '${candidate.intent.labelJa} - ${(candidate.score * 100).round()}%',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '録音品質ガイド',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (result!.qualityIssues.isEmpty)
                        const Text('大きな品質問題は見つかりませんでした。')
                      else
                        ...result!.qualityIssues.map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '・${issue.labelJa} - ${issue.adviceJa}',
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<UserFeedbackLabel>(
                        initialValue: latestRecord?.feedbackLabel,
                        decoration: const InputDecoration(
                          labelText: '実際の印象に近かったか',
                          border: OutlineInputBorder(),
                        ),
                        items: UserFeedbackLabel.values
                            .map(
                              (label) => DropdownMenuItem<UserFeedbackLabel>(
                                value: label,
                                child: Text(label.labelJa),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: onFeedbackChanged,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReverseTranslatorTab extends StatelessWidget {
  const _ReverseTranslatorTab({
    required this.controller,
    required this.result,
    required this.busy,
    required this.profiles,
    required this.selectedProfileId,
    required this.selectedBreed,
    required this.selectedAgeStage,
    required this.selectedSizeClass,
    required this.selectedTension,
    required this.selectedSceneMode,
    required this.statusMessage,
    required this.onProfileChanged,
    required this.onSceneModeChanged,
    required this.onBreedChanged,
    required this.onAgeStageChanged,
    required this.onSizeClassChanged,
    required this.onTensionChanged,
    required this.onTranslatePressed,
  });

  final TextEditingController controller;
  final ReverseTranslationResult? result;
  final bool busy;
  final List<DogProfile> profiles;
  final String? selectedProfileId;
  final DogBreed selectedBreed;
  final DogAgeStage selectedAgeStage;
  final DogSizeClass selectedSizeClass;
  final TensionLevel selectedTension;
  final SceneMode selectedSceneMode;
  final String? statusMessage;
  final ValueChanged<String?> onProfileChanged;
  final ValueChanged<SceneMode?> onSceneModeChanged;
  final ValueChanged<DogBreed?> onBreedChanged;
  final ValueChanged<DogAgeStage?> onAgeStageChanged;
  final ValueChanged<DogSizeClass?> onSizeClassChanged;
  final ValueChanged<TensionLevel?> onTensionChanged;
  final VoidCallback onTranslatePressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reverse Expression',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('人の言葉を犬っぽい鳴き声表現と音声に変換します。犬種、年齢、サイズ、テンションを調整できます。'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: selectedProfileId,
                  decoration: const InputDecoration(
                    labelText: '犬プロフィール',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('プロフィール未選択'),
                    ),
                    ...profiles.map(
                      (profile) => DropdownMenuItem<String?>(
                        value: profile.id,
                        child: Text(profile.name),
                      ),
                    ),
                  ],
                  onChanged: busy ? null : onProfileChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SceneMode>(
                  initialValue: selectedSceneMode,
                  decoration: const InputDecoration(
                    labelText: 'シーン',
                    border: OutlineInputBorder(),
                  ),
                  items: SceneMode.values
                      .map(
                        (mode) => DropdownMenuItem<SceneMode>(
                          value: mode,
                          child: Text(mode.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy ? null : onSceneModeChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DogBreed>(
                  initialValue: selectedBreed,
                  decoration: const InputDecoration(
                    labelText: '犬種プリセット',
                    border: OutlineInputBorder(),
                  ),
                  items: DogBreed.values
                      .map(
                        (breed) => DropdownMenuItem<DogBreed>(
                          value: breed,
                          child: Text(breed.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy ? null : onBreedChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DogAgeStage>(
                        initialValue: selectedAgeStage,
                        decoration: const InputDecoration(
                          labelText: '年齢感',
                          border: OutlineInputBorder(),
                        ),
                        items: DogAgeStage.values
                            .map(
                              (value) => DropdownMenuItem<DogAgeStage>(
                                value: value,
                                child: Text(value.labelJa),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: busy ? null : onAgeStageChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<DogSizeClass>(
                        initialValue: selectedSizeClass,
                        decoration: const InputDecoration(
                          labelText: 'サイズ感',
                          border: OutlineInputBorder(),
                        ),
                        items: DogSizeClass.values
                            .map(
                              (value) => DropdownMenuItem<DogSizeClass>(
                                value: value,
                                child: Text(value.labelJa),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: busy ? null : onSizeClassChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TensionLevel>(
                  initialValue: selectedTension,
                  decoration: const InputDecoration(
                    labelText: 'テンション',
                    border: OutlineInputBorder(),
                  ),
                  items: TensionLevel.values
                      .map(
                        (value) => DropdownMenuItem<TensionLevel>(
                          value: value,
                          child: Text(value.labelJa),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: busy ? null : onTensionChanged,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '例: こっちに来て / Let us play together!',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: busy ? null : onTranslatePressed,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('犬っぽい声に変換して再生'),
                ),
                const SizedBox(height: 12),
                Text(statusMessage ?? '入力後に再生すると犬語っぽい音声を合成します。'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: result == null
                ? const Text('まだ逆変換結果がありません。')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result!.style.labelJa} / ${result!.breed.labelJa}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        result!.dogText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(result!.explanation),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.analyticsSummary,
    required this.comparisonRecords,
    required this.profiles,
    required this.forwardRecords,
  });

  final AnalyticsSummary analyticsSummary;
  final List<ForwardRecord> comparisonRecords;
  final List<DogProfile> profiles;
  final List<ForwardRecord> forwardRecords;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FeatureChip(
              label: 'Forward 保存数',
              value: analyticsSummary.totalForward.toString(),
            ),
            _FeatureChip(
              label: 'Reverse 保存数',
              value: analyticsSummary.totalReverse.toString(),
            ),
            _FeatureChip(
              label: 'フィードバック数',
              value: analyticsSummary.feedbackCount.toString(),
            ),
            _FeatureChip(label: 'プロフィール数', value: profiles.length.toString()),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('感情分布', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (analyticsSummary.intentCounts.isEmpty)
                  const Text('まだ forward 記録がありません。')
                else
                  ...analyticsSummary.intentCounts.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${entry.key}: ${entry.value}'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('シーン分布', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (analyticsSummary.sceneCounts.isEmpty)
                  const Text('まだシーン付き記録がありません。')
                else
                  ...analyticsSummary.sceneCounts.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${entry.key}: ${entry.value}'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('比較ビュー', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (comparisonRecords.length < 2)
                  const Text('履歴から forward 記録を 2 件選ぶと比較できます。')
                else
                  Row(
                    children: comparisonRecords
                        .map(
                          (record) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _ComparisonCard(record: record),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最近の forward 保存',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...forwardRecords
                    .take(5)
                    .map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${record.translation.intent.labelJa} / ${record.sceneMode.labelJa} / ${record.timestampIso}',
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.record});

  final ForwardRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.translation.intent.labelJa),
          const SizedBox(height: 6),
          Text('確信度: ${record.translation.confidence.labelJa}'),
          Text('シーン: ${record.sceneMode.labelJa}'),
          Text(
            '録音長: ${record.translation.features.durationSeconds.toStringAsFixed(2)}s',
          ),
          const SizedBox(height: 8),
          ...record.translation.candidates.map(
            (candidate) => Text(
              '${candidate.intent.labelJa} ${(candidate.score * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPanel extends StatelessWidget {
  const _WaveformPanel({
    required this.isRecording,
    required this.waveformSamples,
  });

  final bool isRecording;
  final List<double> waveformSamples;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRecording ? '録音波形' : '録音待機中',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: waveformSamples.isEmpty
                ? Center(
                    child: Text(
                      '録音を開始すると波形を表示します。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : CustomPaint(
                    painter: _WaveformPainter(samples: waveformSamples),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.samples});

  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    final baselinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / (samples.length * 1.8);

    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      baselinePaint,
    );

    if (samples.isEmpty) {
      return;
    }

    final step = size.width / samples.length;
    for (var i = 0; i < samples.length; i++) {
      final amplitude = samples[i].clamp(0.0, 1.0);
      final barHeight = (size.height * 0.45) * amplitude;
      final x = (i * step) + (step / 2);
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    if (oldDelegate.samples.length != samples.length) {
      return true;
    }
    for (var i = 0; i < samples.length; i++) {
      if (oldDelegate.samples[i] != samples[i]) {
        return true;
      }
    }
    return false;
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.profiles,
    required this.forwardRecords,
    required this.reverseRecords,
    required this.compareSelection,
    required this.onToggleCompare,
  });

  final List<DogProfile> profiles;
  final List<ForwardRecord> forwardRecords;
  final List<ReverseRecord> reverseRecords;
  final Set<String> compareSelection;
  final ValueChanged<String> onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final items = <HistoryEntry>[
      ...forwardRecords.map(
        (record) => HistoryEntry(
          id: record.id,
          mode: InteractionMode.forward,
          title: record.translation.intent.labelJa,
          subtitle: record.translation.explanation,
          timestamp: DateTime.tryParse(record.timestampIso) ?? DateTime.now(),
          isPersisted: true,
        ),
      ),
      ...reverseRecords.map(
        (record) => HistoryEntry(
          id: record.id,
          mode: InteractionMode.reverse,
          title: '${record.style.labelJa} (${record.breed.labelJa})',
          subtitle: record.dogText,
          timestamp: DateTime.tryParse(record.timestampIso) ?? DateTime.now(),
          isPersisted: true,
        ),
      ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('まだ履歴はありません。録音または逆変換を行うとここに表示されます。')
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: entry.mode == InteractionMode.forward
                              ? const Color(0xFFCCFBF1)
                              : const Color(0xFFFDE68A),
                          foregroundColor: const Color(0xFF134E4A),
                          child: Icon(
                            entry.mode == InteractionMode.forward
                                ? Icons.pets
                                : Icons.record_voice_over,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(entry.subtitle),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(entry.timestamp),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              if (entry.mode == InteractionMode.forward)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => onToggleCompare(entry.id),
                                    icon: Icon(
                                      compareSelection.contains(entry.id)
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                    ),
                                    label: const Text('比較に追加'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}

class _CreateProfileDialog extends StatefulWidget {
  const _CreateProfileDialog();

  @override
  State<_CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<_CreateProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DogBreed _breed = DogBreed.mixed;
  DogAgeStage _ageStage = DogAgeStage.adult;
  DogSizeClass _sizeClass = DogSizeClass.medium;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プロフィール追加'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '名前'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogBreed>(
              initialValue: _breed,
              decoration: const InputDecoration(labelText: '犬種'),
              items: DogBreed.values
                  .map(
                    (value) => DropdownMenuItem<DogBreed>(
                      value: value,
                      child: Text(value.labelJa),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _breed = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogAgeStage>(
              initialValue: _ageStage,
              decoration: const InputDecoration(labelText: '年齢感'),
              items: DogAgeStage.values
                  .map(
                    (value) => DropdownMenuItem<DogAgeStage>(
                      value: value,
                      child: Text(value.labelJa),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _ageStage = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogSizeClass>(
              initialValue: _sizeClass,
              decoration: const InputDecoration(labelText: 'サイズ'),
              items: DogSizeClass.values
                  .map(
                    (value) => DropdownMenuItem<DogSizeClass>(
                      value: value,
                      child: Text(value.labelJa),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _sizeClass = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'メモ'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              DogProfile(
                id: 'profile-${DateTime.now().microsecondsSinceEpoch}',
                name: name,
                breed: _breed,
                ageStage: _ageStage,
                sizeClass: _sizeClass,
                notes: _notesController.text.trim(),
                createdAtIso: DateTime.now().toIso8601String(),
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
