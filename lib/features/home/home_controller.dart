import 'dart:async';
import 'dart:io';

import 'package:dog_translator/domain/analytics_service.dart';
import 'package:dog_translator/domain/audio_feature_extractor.dart';
import 'package:dog_translator/domain/dog_intent_interpreter.dart';
import 'package:dog_translator/domain/inference_provider.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/domain/reverse_translator.dart';
import 'package:dog_translator/features/home/widgets/create_profile_dialog.dart';
import 'package:dog_translator/services/app_repository.dart';
import 'package:dog_translator/services/bark_playback_service.dart';
import 'package:dog_translator/services/inference_provider_factory.dart';
import 'package:dog_translator/services/recording_service.dart';
import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required RecordingService recordingService,
    required BarkPlaybackService playbackService,
    required AppRepository repository,
    required ValueChanged<AppThemePreset> onThemePresetChanged,
    AudioFeatureExtractor? featureExtractor,
    InferenceProviderFactory? inferenceProviderFactory,
    ReverseTranslator? reverseTranslator,
    AnalyticsService? analyticsService,
  }) : _recordingService = recordingService,
       _playbackService = playbackService,
       _repository = repository,
       _onThemePresetChanged = onThemePresetChanged,
       _featureExtractor = featureExtractor ?? const AudioFeatureExtractor(),
       _inferenceProviderFactory =
           inferenceProviderFactory ?? const InferenceProviderFactory(),
       _reverseTranslator = reverseTranslator ?? ReverseTranslator(),
       _analyticsService = analyticsService ?? const AnalyticsService() {
    _selectedInputDeviceId = _recordingService.selectedInputDeviceId;
  }

  final RecordingService _recordingService;
  final BarkPlaybackService _playbackService;
  final AppRepository _repository;
  final ValueChanged<AppThemePreset> _onThemePresetChanged;
  final AudioFeatureExtractor _featureExtractor;
  final InferenceProviderFactory _inferenceProviderFactory;
  final ReverseTranslator _reverseTranslator;
  final AnalyticsService _analyticsService;
  static const InferenceProvider _defaultInferenceProvider =
      DogIntentInterpreter();

  final TextEditingController reverseTextController = TextEditingController();
  final List<double> _waveformSamples = <double>[];
  final Set<String> _comparisonSelection = <String>{};

  StreamSubscription<double>? _amplitudeSubscription;
  TranslationResult? _translationResult;
  ReverseTranslationResult? _reverseResult;
  InferenceProvider _inferenceProvider = _defaultInferenceProvider;
  String? _selectedRecordId;
  DateTime? _analysisStartedAt;
  List<RecordingInputDevice> _inputDevices = const <RecordingInputDevice>[];
  List<DogProfile> _profiles = const <DogProfile>[];
  List<ForwardRecord> _forwardRecords = const <ForwardRecord>[];
  List<ReverseRecord> _reverseRecords = const <ReverseRecord>[];
  String? _selectedInputDeviceId;
  String? _selectedProfileId;
  String? _historyProfileFilterId;
  String? _dashboardProfileFilterId;
  String? _historyIntentFilterLabel;
  String _historySearchQuery = '';
  InferenceModelSelection _selectedInferenceModel =
      InferenceModelSelection.auto;
  InferenceModelSelection _activeInferenceModel =
      InferenceModelSelection.heuristic;
  AppThemePreset _selectedThemePreset = AppThemePreset.defaultTeal;
  DogBreed _selectedBreed = DogBreed.mixed;
  DogAgeStage _selectedAgeStage = DogAgeStage.adult;
  DogSizeClass _selectedSizeClass = DogSizeClass.medium;
  TensionLevel _selectedTension = TensionLevel.normal;
  SceneMode _selectedSceneMode = SceneMode.home;
  bool _recordingBusy = false;
  bool _reverseBusy = false;
  bool _analysisInProgress = false;
  bool _loadingInputDevices = true;
  bool _loadingAppData = true;
  bool _loadingInferenceModel = true;
  double? _analysisProgress;
  String? _analysisStageMessage;
  String? _forwardStatusMessage;
  String? _reverseStatusMessage;
  String? _inferenceStatusMessage;

  TranslationResult? get translationResult => _translationResult;
  ReverseTranslationResult? get reverseResult => _reverseResult;
  List<RecordingInputDevice> get inputDevices => _inputDevices;
  List<DogProfile> get profiles => _profiles;
  List<ForwardRecord> get forwardRecords => _forwardRecords;
  List<ReverseRecord> get reverseRecords => _reverseRecords;
  String? get selectedInputDeviceId => _selectedInputDeviceId;
  String? get selectedProfileId => _selectedProfileId;
  String? get historyProfileFilterId => _historyProfileFilterId;
  String? get dashboardProfileFilterId => _dashboardProfileFilterId;
  String? get historyIntentFilterLabel => _historyIntentFilterLabel;
  String get historySearchQuery => _historySearchQuery;
  InferenceModelSelection get selectedInferenceModel => _selectedInferenceModel;
  InferenceModelSelection get activeInferenceModel => _activeInferenceModel;
  AppThemePreset get selectedThemePreset => _selectedThemePreset;
  DogBreed get selectedBreed => _selectedBreed;
  DogAgeStage get selectedAgeStage => _selectedAgeStage;
  DogSizeClass get selectedSizeClass => _selectedSizeClass;
  TensionLevel get selectedTension => _selectedTension;
  SceneMode get selectedSceneMode => _selectedSceneMode;
  bool get recordingBusy => _recordingBusy;
  bool get reverseBusy => _reverseBusy;
  bool get analysisInProgress => _analysisInProgress;
  bool get loadingInputDevices => _loadingInputDevices;
  bool get loadingAppData => _loadingAppData;
  bool get loadingInferenceModel => _loadingInferenceModel;
  bool get isRecording => _recordingService.isRecording;
  String? get forwardStatusMessage => _forwardStatusMessage;
  String? get reverseStatusMessage => _reverseStatusMessage;
  String? get inferenceStatusMessage => _inferenceStatusMessage;
  double? get analysisProgress => _analysisProgress;
  String? get analysisStageMessage => _analysisStageMessage;
  String? get analysisEstimatedRemainingLabel {
    final startedAt = _analysisStartedAt;
    final progress = _analysisProgress;
    if (!_analysisInProgress ||
        startedAt == null ||
        progress == null ||
        progress <= 0 ||
        progress >= 1) {
      return null;
    }
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    final totalMs = (elapsedMs / progress).round();
    final remainingMs = (totalMs - elapsedMs).clamp(0, 3600000);
    final seconds = (remainingMs / 1000).ceil();
    return '推定残り ${seconds}s';
  }

  List<double> get waveformSamples =>
      List<double>.unmodifiable(_waveformSamples);
  Set<String> get comparisonSelection =>
      Set<String>.unmodifiable(_comparisonSelection);

  ForwardRecord? get selectedForwardRecord =>
      _selectedRecordId == null ? null : findForwardRecord(_selectedRecordId!);

  ForwardRecord? get latestForwardRecord => selectedForwardRecord;

  DogProfile? get selectedProfile {
    for (final profile in _profiles) {
      if (profile.id == _selectedProfileId) {
        return profile;
      }
    }
    return null;
  }

  Map<String, String> get profileNameById => <String, String>{
    for (final profile in _profiles) profile.id: profile.name,
  };

  List<String> get availableHistoryIntentLabels =>
      _forwardRecords
          .map((record) => record.translation.intent.labelJa)
          .toSet()
          .toList(growable: false)
        ..sort();

  List<MapEntry<String, String>> get availableHistoryProfileFilters => _profiles
      .map((profile) => MapEntry(profile.id, profile.name))
      .toList(growable: false);

  List<ForwardRecord> get filteredHistoryRecords {
    final query = _historySearchQuery.trim().toLowerCase();
    return _forwardRecords
        .where((record) {
          if (_historyIntentFilterLabel != null &&
              record.translation.intent.labelJa != _historyIntentFilterLabel) {
            return false;
          }
          if (_historyProfileFilterId != null &&
              record.profileId != _historyProfileFilterId) {
            return false;
          }
          if (query.isEmpty) {
            return true;
          }
          final profileName = profileNameById[record.profileId] ?? '';
          final haystack = [
            record.translation.intent.labelJa,
            record.translation.explanation,
            record.sceneMode.labelJa,
            profileName,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  AnalyticsSummary get analyticsSummary => _analyticsService.summarize(
    _forwardRecords,
    _reverseRecords,
    _profiles,
    profileFilterId: _dashboardProfileFilterId,
  );

  List<ForwardRecord> get dashboardForwardRecords {
    if (_dashboardProfileFilterId == null) {
      return _forwardRecords;
    }
    return _forwardRecords
        .where((record) => record.profileId == _dashboardProfileFilterId)
        .toList(growable: false);
  }

  List<ForwardRecord> get comparisonRecords {
    final records = _forwardRecords
        .where((record) => _comparisonSelection.contains(record.id))
        .toList(growable: false);
    records.sort((a, b) => b.timestampIso.compareTo(a.timestampIso));
    return records.take(2).toList(growable: false);
  }

  Future<void> initialize() async {
    await loadAppData();
    await Future.wait([loadInferenceProvider(), loadInputDevices()]);
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    reverseTextController.dispose();
    _recordingService.dispose();
    _playbackService.dispose();
    super.dispose();
  }

  Future<void> loadAppData() async {
    final data = await _repository.load();
    _profiles = data.profiles;
    _forwardRecords = data.forwardRecords;
    _reverseRecords = data.reverseRecords;
    _selectedProfileId = data.settings.selectedProfileId;
    _selectedInputDeviceId =
        data.settings.selectedInputDeviceId ?? _selectedInputDeviceId;
    _selectedInferenceModel = data.settings.selectedInferenceModel;
    _selectedThemePreset = data.settings.selectedThemePreset;
    _selectedBreed = data.settings.selectedBreed;
    _selectedAgeStage = data.settings.selectedAgeStage;
    _selectedSizeClass = data.settings.selectedSizeClass;
    _selectedTension = data.settings.selectedTension;
    _selectedSceneMode = data.settings.selectedSceneMode;
    _selectedRecordId = _forwardRecords.isEmpty
        ? null
        : _forwardRecords.first.id;
    _translationResult = _selectedRecordId == null
        ? null
        : _forwardRecords.first.translation;
    _loadingAppData = false;
    _onThemePresetChanged(_selectedThemePreset);
    notifyListeners();
  }

  Future<void> persistState() {
    return _repository.save(
      AppData(
        profiles: _profiles,
        forwardRecords: _forwardRecords,
        reverseRecords: _reverseRecords,
        settings: AppSettings(
          selectedProfileId: _selectedProfileId,
          selectedInputDeviceId: _selectedInputDeviceId,
          selectedInferenceModel: _selectedInferenceModel,
          selectedThemePreset: _selectedThemePreset,
          selectedBreed: _selectedBreed,
          selectedAgeStage: _selectedAgeStage,
          selectedSizeClass: _selectedSizeClass,
          selectedTension: _selectedTension,
          selectedSceneMode: _selectedSceneMode,
        ),
      ),
    );
  }

  Future<void> loadInputDevices() async {
    _loadingInputDevices = true;
    notifyListeners();
    try {
      final devices = await _recordingService.listInputDevices();
      _inputDevices = devices;
      final currentId = _selectedInputDeviceId;
      if (currentId != null &&
          devices.every((device) => device.id != currentId)) {
        _selectedInputDeviceId = null;
        _forwardStatusMessage = '選択中のマイクが見つからないため、既定の入力に戻しました。';
      }
      await persistState();
    } catch (error) {
      _forwardStatusMessage = '入力マイク一覧の取得に失敗しました: $error';
    } finally {
      _loadingInputDevices = false;
      notifyListeners();
    }
  }

  Future<void> loadInferenceProvider() async {
    _loadingInferenceModel = true;
    notifyListeners();
    try {
      final resolution = await _inferenceProviderFactory.create(
        selection: _selectedInferenceModel,
      );
      _inferenceProvider = resolution.provider;
      _activeInferenceModel = resolution.activeModel;
      _inferenceStatusMessage = resolution.statusMessage;
      if (resolution.requestedModel != _selectedInferenceModel) {
        _selectedInferenceModel = resolution.requestedModel;
      }
      await persistState();
    } catch (error) {
      _inferenceProvider = _defaultInferenceProvider;
      _activeInferenceModel = InferenceModelSelection.heuristic;
      _inferenceStatusMessage = '推論モデルの初期化に失敗しました。標準ヒューリスティック推論を使用します: $error';
    } finally {
      _loadingInferenceModel = false;
      notifyListeners();
    }
  }

  Future<void> selectInputDevice(String? deviceId) async {
    if (_recordingBusy || _recordingService.isRecording) {
      return;
    }
    await _recordingService.selectInputDevice(deviceId);
    _selectedInputDeviceId = deviceId;
    _forwardStatusMessage = deviceId == null
        ? '既定のマイクを使用する設定にしました。'
        : '入力マイクを切り替えました。';
    notifyListeners();
    await persistState();
  }

  Future<void> setInferenceModel(InferenceModelSelection? selection) async {
    if (selection == null || _recordingBusy || _recordingService.isRecording) {
      return;
    }
    _selectedInferenceModel = selection;
    await loadInferenceProvider();
  }

  Future<void> setThemePreset(AppThemePreset? preset) async {
    if (preset == null) {
      return;
    }
    _selectedThemePreset = preset;
    _onThemePresetChanged(preset);
    notifyListeners();
    await persistState();
  }

  Future<void> toggleRecording() async {
    if (_recordingBusy) {
      return;
    }

    _recordingBusy = true;
    _forwardStatusMessage = null;
    notifyListeners();

    try {
      if (_recordingService.isRecording) {
        await _amplitudeSubscription?.cancel();
        _amplitudeSubscription = null;

        final path = await _recordingService.stop();
        if (path == null || !await File(path).exists()) {
          _forwardStatusMessage = '録音ファイルを取得できませんでした。';
          return;
        }

        _analysisStartedAt = DateTime.now();
        _setAnalysisProgress(
          inProgress: true,
          progress: 0.1,
          message: '録音データを読み込んでいます...',
        );
        final bytes = await File(path).readAsBytes();
        _setAnalysisProgress(
          inProgress: true,
          progress: 0.24,
          message: '音声特徴を抽出しています...',
        );
        final features = _featureExtractor.extractFromWavBytes(bytes);
        _setAnalysisProgress(
          inProgress: true,
          progress: 0.42,
          message: '録音品質を確認しています...',
        );
        _setAnalysisProgress(
          inProgress: true,
          progress: 0.68,
          message: '推論モデルで解析しています...',
        );
        final result = await _inferenceProvider.analyze(
          features,
          profile: selectedProfile,
          sceneMode: _selectedSceneMode,
          wavBytes: bytes,
        );
        _setAnalysisProgress(
          inProgress: true,
          progress: 0.86,
          message: '履歴へ保存しています...',
        );
        final recordId = _createId('fwd');
        final recordingPath = await _repository.saveRecording(bytes, recordId);
        final record = ForwardRecord(
          id: recordId,
          timestampIso: DateTime.now().toIso8601String(),
          profileId: _selectedProfileId,
          sceneMode: _selectedSceneMode,
          translation: result,
          recordingPath: recordingPath,
          feedbackLabel: null,
        );

        _setAnalysisProgress(
          inProgress: true,
          progress: 0.96,
          message: '画面へ結果を反映しています...',
        );
        _translationResult = result;
        _selectedRecordId = recordId;
        _forwardRecords = <ForwardRecord>[record, ..._forwardRecords];
        _forwardStatusMessage = '録音を解析しました。';
        await persistState();
      } else {
        final hasPermission = await _recordingService.hasPermission();
        if (!hasPermission) {
          _forwardStatusMessage = 'マイクへのアクセスが許可されていません。';
          return;
        }

        await _recordingService.selectInputDevice(_selectedInputDeviceId);
        await _recordingService.start();
        _waveformSamples
          ..clear()
          ..addAll(List<double>.filled(48, 0));
        _beginWaveformSampling();
        _forwardStatusMessage = '録音中です。もう一度押すと解析します。';
      }
    } on FormatException catch (error) {
      _forwardStatusMessage = '録音解析に失敗しました: ${error.message}';
    } catch (error) {
      _forwardStatusMessage = '録音処理でエラーが発生しました: $error';
    } finally {
      _recordingBusy = false;
      _analysisStartedAt = null;
      _analysisInProgress = false;
      _analysisProgress = null;
      _analysisStageMessage = null;
      notifyListeners();
    }
  }

  void _setAnalysisProgress({
    required bool inProgress,
    required double? progress,
    required String? message,
  }) {
    _analysisInProgress = inProgress;
    _analysisProgress = progress;
    _analysisStageMessage = message;
    notifyListeners();
  }

  void _beginWaveformSampling() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = _recordingService.amplitudeStream().listen((
      value,
    ) {
      if (!_recordingService.isRecording) {
        return;
      }
      if (_waveformSamples.length >= 48) {
        _waveformSamples.removeAt(0);
      }
      _waveformSamples.add(value.clamp(0.0, 1.0));
      notifyListeners();
    });
  }

  Future<void> runReverseTranslation() async {
    if (_reverseBusy) {
      return;
    }

    _reverseBusy = true;
    _reverseStatusMessage = null;
    notifyListeners();

    try {
      final result = _reverseTranslator.translate(
        reverseTextController.text,
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

      _reverseResult = result;
      _reverseRecords = <ReverseRecord>[record, ..._reverseRecords];
      _reverseStatusMessage = '犬っぽい表現を生成しました。音声を再生します。';
      await persistState();
      notifyListeners();

      unawaited(_playReverseAudio(result));
    } catch (error) {
      _reverseStatusMessage = '逆変換の生成でエラーが発生しました: $error';
    } finally {
      _reverseBusy = false;
      notifyListeners();
    }
  }

  Future<void> _playReverseAudio(ReverseTranslationResult result) async {
    try {
      await _playbackService.play(result.audioBytes);
      _reverseStatusMessage = '犬っぽい音声を再生しました。';
    } catch (error) {
      _reverseStatusMessage = '音声は生成しましたが、再生に失敗しました: $error';
    }
    notifyListeners();
  }

  Future<void> applyFeedback(UserFeedbackLabel? label) async {
    final recordId = _selectedRecordId;
    if (recordId == null || label == null) {
      return;
    }

    _forwardRecords = _forwardRecords
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
    notifyListeners();
    await persistState();
  }

  Future<void> createProfile(BuildContext context) async {
    final created = await showDialog<DogProfile>(
      context: context,
      builder: (context) => const CreateProfileDialog(),
    );
    if (created == null) {
      return;
    }

    _profiles = <DogProfile>[created, ..._profiles];
    _selectedProfileId = created.id;
    _selectedBreed = created.breed;
    _selectedAgeStage = created.ageStage;
    _selectedSizeClass = created.sizeClass;
    _forwardStatusMessage = 'プロフィールを追加しました。';
    notifyListeners();
    await persistState();
  }

  Future<void> editProfile(BuildContext context, DogProfile profile) async {
    final updated = await showDialog<DogProfile>(
      context: context,
      builder: (context) => CreateProfileDialog.edit(initialProfile: profile),
    );
    if (updated == null) {
      return;
    }

    _profiles = _profiles
        .map((item) => item.id == updated.id ? updated : item)
        .toList(growable: false);
    if (_selectedProfileId == updated.id) {
      _selectedBreed = updated.breed;
      _selectedAgeStage = updated.ageStage;
      _selectedSizeClass = updated.sizeClass;
    }
    notifyListeners();
    await persistState();
  }

  Future<void> deleteProfile(String profileId) async {
    _profiles = _profiles
        .where((profile) => profile.id != profileId)
        .toList(growable: false);
    if (_selectedProfileId == profileId) {
      _selectedProfileId = null;
    }
    if (_historyProfileFilterId == profileId) {
      _historyProfileFilterId = null;
    }
    if (_dashboardProfileFilterId == profileId) {
      _dashboardProfileFilterId = null;
    }
    notifyListeners();
    await persistState();
  }

  Future<void> addLatestRecordingToProfileCalibration(String profileId) async {
    final record = latestForwardRecord;
    if (record == null) {
      _forwardStatusMessage = '個体サンプルに追加するための最新録音がありません。';
      notifyListeners();
      return;
    }

    _profiles = _profiles
        .map((profile) {
          if (profile.id != profileId) {
            return profile;
          }
          final calibration =
              profile.voiceCalibration ??
              const DogVoiceCalibration(
                sampleCount: 0,
                averagePitchHz: 0,
                averageRms: 0,
                averageActivityRatio: 0,
                lastSampleAtIso: null,
              );
          return profile.copyWith(
            voiceCalibration: calibration.mergeSample(
              pitchHz: record.translation.features.pitchHz,
              rms: record.translation.features.rms,
              activityRatio: record.translation.features.activityRatio,
              timestampIso: record.timestampIso,
            ),
          );
        })
        .toList(growable: false);

    _forwardStatusMessage = '最新録音を個体サンプルとして追加しました。';
    notifyListeners();
    await persistState();
  }

  Future<void> selectProfile(String? profileId) async {
    _selectedProfileId = profileId;
    final profile = selectedProfile;
    if (profile != null) {
      _selectedBreed = profile.breed;
      _selectedAgeStage = profile.ageStage;
      _selectedSizeClass = profile.sizeClass;
    }
    notifyListeners();
    await persistState();
  }

  Future<void> setSceneMode(SceneMode? mode) async {
    if (mode == null) {
      return;
    }
    _selectedSceneMode = mode;
    notifyListeners();
    await persistState();
  }

  Future<void> setBreed(DogBreed? breed) async {
    if (breed == null) {
      return;
    }
    _selectedBreed = breed;
    notifyListeners();
    await persistState();
  }

  Future<void> setAgeStage(DogAgeStage? ageStage) async {
    if (ageStage == null) {
      return;
    }
    _selectedAgeStage = ageStage;
    notifyListeners();
    await persistState();
  }

  Future<void> setSizeClass(DogSizeClass? sizeClass) async {
    if (sizeClass == null) {
      return;
    }
    _selectedSizeClass = sizeClass;
    notifyListeners();
    await persistState();
  }

  Future<void> setTension(TensionLevel? tension) async {
    if (tension == null) {
      return;
    }
    _selectedTension = tension;
    notifyListeners();
    await persistState();
  }

  void setHistorySearchQuery(String value) {
    _historySearchQuery = value;
    notifyListeners();
  }

  void setHistoryIntentFilter(String? label) {
    _historyIntentFilterLabel = label;
    notifyListeners();
  }

  void setHistoryProfileFilter(String? profileId) {
    _historyProfileFilterId = profileId;
    notifyListeners();
  }

  void clearHistoryFilters() {
    _historyIntentFilterLabel = null;
    _historyProfileFilterId = null;
    _historySearchQuery = '';
    notifyListeners();
  }

  void setDashboardProfileFilter(String? profileId) {
    _dashboardProfileFilterId = profileId;
    notifyListeners();
  }

  void selectHistoryIntentFromDashboard(String label) {
    _historyIntentFilterLabel = label;
    notifyListeners();
  }

  void toggleCompareSelection(String id) {
    if (_comparisonSelection.contains(id)) {
      _comparisonSelection.remove(id);
    } else {
      if (_comparisonSelection.length >= 2) {
        _comparisonSelection.remove(_comparisonSelection.first);
      }
      _comparisonSelection.add(id);
    }
    notifyListeners();
  }

  ForwardRecord? findForwardRecord(String id) {
    for (final record in _forwardRecords) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }

  void selectForwardRecord(String id) {
    final record = findForwardRecord(id);
    if (record == null) {
      return;
    }
    _selectedRecordId = id;
    _translationResult = record.translation;
    _selectedProfileId = record.profileId;
    _selectedSceneMode = record.sceneMode;
    _forwardStatusMessage = '履歴の解析結果を表示しています。';
    notifyListeners();
  }

  Future<void> playForwardRecord(String id) async {
    final record = findForwardRecord(id);
    final path = record?.recordingPath;
    if (path == null || path.isEmpty) {
      _forwardStatusMessage = 'このセッションに再生できる録音ファイルがありません。';
      notifyListeners();
      return;
    }

    try {
      await _playbackService.playFile(path);
      _forwardStatusMessage = 'セッション録音を再生しました。';
    } catch (error) {
      _forwardStatusMessage = 'セッション録音の再生に失敗しました: $error';
    }
    notifyListeners();
  }

  Future<void> deleteForwardRecord(String id) async {
    final record = findForwardRecord(id);
    final path = record?.recordingPath;
    if (path != null && path.isNotEmpty) {
      unawaited(_deleteFileIfExists(path));
    }
    _forwardRecords = _forwardRecords
        .where((record) => record.id != id)
        .toList(growable: false);
    _comparisonSelection.remove(id);
    if (_selectedRecordId == id) {
      final replacement = _forwardRecords.isEmpty
          ? null
          : _forwardRecords.first;
      _selectedRecordId = replacement?.id;
      _translationResult = replacement?.translation;
    }
    notifyListeners();
    await persistState();
  }

  Future<void> deleteAllForwardRecords() async {
    for (final record in _forwardRecords) {
      final path = record.recordingPath;
      if (path != null && path.isNotEmpty) {
        unawaited(_deleteFileIfExists(path));
      }
    }
    _forwardRecords = const <ForwardRecord>[];
    _comparisonSelection.clear();
    _selectedRecordId = null;
    _translationResult = null;
    notifyListeners();
    await persistState();
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _createId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
