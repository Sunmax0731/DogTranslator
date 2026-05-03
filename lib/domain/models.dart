import 'dart:convert';
import 'dart:typed_data';

enum ConfidenceLevel { high, medium, low }

extension ConfidenceLevelText on ConfidenceLevel {
  String get labelJa {
    switch (this) {
      case ConfidenceLevel.high:
        return '高め';
      case ConfidenceLevel.medium:
        return '中くらい';
      case ConfidenceLevel.low:
        return '低め';
    }
  }

  String get key => name;

  static ConfidenceLevel fromKey(String? key) {
    return ConfidenceLevel.values.firstWhere(
      (value) => value.name == key,
      orElse: () => ConfidenceLevel.low,
    );
  }
}

enum DogIntent {
  excitedGreeting,
  attentionSeeking,
  warningAlert,
  anxiousWhine,
  sleepy,
  restlessEnergy,
  happyRelaxed,
  bored,
  uncertain,
}

extension DogIntentText on DogIntent {
  String get labelJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return '遊びたい';
      case DogIntent.attentionSeeking:
        return 'かまってほしい';
      case DogIntent.warningAlert:
        return '警戒している';
      case DogIntent.anxiousWhine:
        return 'さみしい / 甘えたい';
      case DogIntent.sleepy:
        return 'ねむたい';
      case DogIntent.restlessEnergy:
        return 'そわそわしている';
      case DogIntent.happyRelaxed:
        return 'うれしく落ち着いている';
      case DogIntent.bored:
        return '退屈している';
      case DogIntent.uncertain:
        return '判断が難しい';
    }
  }

  String get explanationJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return '短く勢いのある鳴き方が続いていて、遊びや歓迎の気分が強そうです。';
      case DogIntent.attentionSeeking:
        return '呼びかけるようなリズムがあり、こちらに気づいてほしい様子です。';
      case DogIntent.warningAlert:
        return '音量が大きく鋭い鳴き方で、警戒や威嚇を示している可能性があります。';
      case DogIntent.anxiousWhine:
        return '長めで弱い鳴き方が多く、不安や甘えの傾向がありそうです。';
      case DogIntent.sleepy:
        return '穏やかで弱い音が続いていて、眠そうな気分に見えます。';
      case DogIntent.restlessEnergy:
        return '勢いはあるものの落ち着かない様子で、そわそわした反応に近そうです。';
      case DogIntent.happyRelaxed:
        return '比較的安定した鳴き方で、安心感や機嫌の良さがにじんでいます。';
      case DogIntent.bored:
        return '反応はあるものの刺激が足りず、退屈さが混じっていそうです。';
      case DogIntent.uncertain:
        return '音量や長さの特徴が弱く、今回の録音だけでは意図の特定が難しいです。';
    }
  }

  static DogIntent fromKey(String? key) {
    return DogIntent.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogIntent.uncertain,
    );
  }
}

enum RecordingQualityIssue { tooShort, lowVolume, peakyInput, unstableNoise }

extension RecordingQualityIssueText on RecordingQualityIssue {
  String get labelJa {
    switch (this) {
      case RecordingQualityIssue.tooShort:
        return '録音が短すぎます';
      case RecordingQualityIssue.lowVolume:
        return '音量が弱めです';
      case RecordingQualityIssue.peakyInput:
        return '瞬間的な大音量が目立ちます';
      case RecordingQualityIssue.unstableNoise:
        return '雑音が多い可能性があります';
    }
  }

  String get adviceJa {
    switch (this) {
      case RecordingQualityIssue.tooShort:
        return 'もう少し長めに録音すると判断しやすくなります。';
      case RecordingQualityIssue.lowVolume:
        return 'マイクを近づけるか、もう少し大きな音が入るようにしてください。';
      case RecordingQualityIssue.peakyInput:
        return '急な物音が混ざっていないか確認してください。';
      case RecordingQualityIssue.unstableNoise:
        return '静かな環境か、雑音の少ない位置で録音してください。';
    }
  }

  static RecordingQualityIssue fromKey(String? key) {
    return RecordingQualityIssue.values.firstWhere(
      (value) => value.name == key,
      orElse: () => RecordingQualityIssue.unstableNoise,
    );
  }
}

enum ReverseEmotionStyle {
  playful,
  friendly,
  requesting,
  alert,
  anxious,
  neutral,
}

extension ReverseEmotionStyleText on ReverseEmotionStyle {
  String get labelJa {
    switch (this) {
      case ReverseEmotionStyle.playful:
        return '遊びたい';
      case ReverseEmotionStyle.friendly:
        return '親しみ';
      case ReverseEmotionStyle.requesting:
        return 'お願い';
      case ReverseEmotionStyle.alert:
        return '警戒';
      case ReverseEmotionStyle.anxious:
        return '不安';
      case ReverseEmotionStyle.neutral:
        return 'ニュートラル';
    }
  }
}

enum DogBreed { mixed, shiba, chihuahua, toyPoodle, goldenRetriever, husky }

extension DogBreedText on DogBreed {
  String get labelJa {
    switch (this) {
      case DogBreed.mixed:
        return 'ミックス';
      case DogBreed.shiba:
        return '柴犬';
      case DogBreed.chihuahua:
        return 'チワワ';
      case DogBreed.toyPoodle:
        return 'トイプードル';
      case DogBreed.goldenRetriever:
        return 'ゴールデンレトリバー';
      case DogBreed.husky:
        return 'ハスキー';
    }
  }

  String get descriptionJa {
    switch (this) {
      case DogBreed.mixed:
        return '標準的な犬声に近い、汎用プリセットです。';
      case DogBreed.shiba:
        return '日本犬らしい引き締まった鳴き方を意識したプリセットです。';
      case DogBreed.chihuahua:
        return '高めで軽い鳴き方を強めに寄せた小型犬プリセットです。';
      case DogBreed.toyPoodle:
        return '明るく細かな声色を意識したプリセットです。';
      case DogBreed.goldenRetriever:
        return 'やわらかく豊かな鳴き方に寄せた大型犬プリセットです。';
      case DogBreed.husky:
        return '遠吠え寄りの響きを少し加えたプリセットです。';
    }
  }

  static DogBreed fromKey(String? key) {
    return DogBreed.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogBreed.mixed,
    );
  }
}

enum DogAgeStage { puppy, adult, senior }

extension DogAgeStageText on DogAgeStage {
  String get labelJa {
    switch (this) {
      case DogAgeStage.puppy:
        return '子犬';
      case DogAgeStage.adult:
        return '成犬';
      case DogAgeStage.senior:
        return 'シニア';
    }
  }

  static DogAgeStage fromKey(String? key) {
    return DogAgeStage.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogAgeStage.adult,
    );
  }
}

enum DogSizeClass { small, medium, large }

extension DogSizeClassText on DogSizeClass {
  String get labelJa {
    switch (this) {
      case DogSizeClass.small:
        return '小型';
      case DogSizeClass.medium:
        return '中型';
      case DogSizeClass.large:
        return '大型';
    }
  }

  static DogSizeClass fromKey(String? key) {
    return DogSizeClass.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogSizeClass.medium,
    );
  }
}

enum TensionLevel { calm, normal, excited }

extension TensionLevelText on TensionLevel {
  String get labelJa {
    switch (this) {
      case TensionLevel.calm:
        return '落ち着き';
      case TensionLevel.normal:
        return '標準';
      case TensionLevel.excited:
        return '高め';
    }
  }

  static TensionLevel fromKey(String? key) {
    return TensionLevel.values.firstWhere(
      (value) => value.name == key,
      orElse: () => TensionLevel.normal,
    );
  }
}

enum SceneMode { home, playtime, mealtime, walk, guest, night }

extension SceneModeText on SceneMode {
  String get labelJa {
    switch (this) {
      case SceneMode.home:
        return '通常';
      case SceneMode.playtime:
        return '遊び';
      case SceneMode.mealtime:
        return '食事';
      case SceneMode.walk:
        return '散歩';
      case SceneMode.guest:
        return '来客';
      case SceneMode.night:
        return '夜間';
    }
  }

  static SceneMode fromKey(String? key) {
    return SceneMode.values.firstWhere(
      (value) => value.name == key,
      orElse: () => SceneMode.home,
    );
  }
}

enum UserFeedbackLabel { matched, close, off }

extension UserFeedbackLabelText on UserFeedbackLabel {
  String get labelJa {
    switch (this) {
      case UserFeedbackLabel.matched:
        return 'かなり近い';
      case UserFeedbackLabel.close:
        return '少し近い';
      case UserFeedbackLabel.off:
        return '違った';
    }
  }

  static UserFeedbackLabel fromKey(String? key) {
    return UserFeedbackLabel.values.firstWhere(
      (value) => value.name == key,
      orElse: () => UserFeedbackLabel.close,
    );
  }
}

class AudioFeatures {
  const AudioFeatures({
    required this.durationSeconds,
    required this.rms,
    required this.peak,
    required this.zeroCrossingRate,
    required this.burstCount,
    required this.dynamicRange,
    required this.spectralCentroid,
    required this.highBandRatio,
  });

  final double durationSeconds;
  final double rms;
  final double peak;
  final double zeroCrossingRate;
  final int burstCount;
  final double dynamicRange;
  final double spectralCentroid;
  final double highBandRatio;

  Map<String, dynamic> toJson() {
    return {
      'durationSeconds': durationSeconds,
      'rms': rms,
      'peak': peak,
      'zeroCrossingRate': zeroCrossingRate,
      'burstCount': burstCount,
      'dynamicRange': dynamicRange,
      'spectralCentroid': spectralCentroid,
      'highBandRatio': highBandRatio,
    };
  }

  factory AudioFeatures.fromJson(Map<String, dynamic> json) {
    return AudioFeatures(
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0,
      rms: (json['rms'] as num?)?.toDouble() ?? 0,
      peak: (json['peak'] as num?)?.toDouble() ?? 0,
      zeroCrossingRate: (json['zeroCrossingRate'] as num?)?.toDouble() ?? 0,
      burstCount: (json['burstCount'] as num?)?.toInt() ?? 0,
      dynamicRange: (json['dynamicRange'] as num?)?.toDouble() ?? 0,
      spectralCentroid: (json['spectralCentroid'] as num?)?.toDouble() ?? 0,
      highBandRatio: (json['highBandRatio'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TranslationCandidate {
  const TranslationCandidate({required this.intent, required this.score});

  final DogIntent intent;
  final double score;

  Map<String, dynamic> toJson() {
    return {'intent': intent.name, 'score': score};
  }

  factory TranslationCandidate.fromJson(Map<String, dynamic> json) {
    return TranslationCandidate(
      intent: DogIntentText.fromKey(json['intent'] as String?),
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TranslationResult {
  const TranslationResult({
    required this.intent,
    required this.explanation,
    required this.confidence,
    required this.features,
    required this.candidates,
    required this.qualityIssues,
  });

  final DogIntent intent;
  final String explanation;
  final ConfidenceLevel confidence;
  final AudioFeatures features;
  final List<TranslationCandidate> candidates;
  final List<RecordingQualityIssue> qualityIssues;

  Map<String, dynamic> toJson() {
    return {
      'intent': intent.name,
      'explanation': explanation,
      'confidence': confidence.key,
      'features': features.toJson(),
      'candidates': candidates.map((candidate) => candidate.toJson()).toList(),
      'qualityIssues': qualityIssues.map((issue) => issue.name).toList(),
    };
  }

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    final candidateJson = json['candidates'] as List<dynamic>? ?? const [];
    final qualityJson = json['qualityIssues'] as List<dynamic>? ?? const [];
    return TranslationResult(
      intent: DogIntentText.fromKey(json['intent'] as String?),
      explanation: json['explanation'] as String? ?? '',
      confidence: ConfidenceLevelText.fromKey(json['confidence'] as String?),
      features: AudioFeatures.fromJson(
        (json['features'] as Map<dynamic, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
      candidates: candidateJson
          .map(
            (value) => TranslationCandidate.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      qualityIssues: qualityJson
          .map((value) => RecordingQualityIssueText.fromKey(value as String?))
          .toList(growable: false),
    );
  }
}

class ReverseTranslationResult {
  const ReverseTranslationResult({
    required this.style,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.tension,
    required this.dogText,
    required this.explanation,
    required this.audioBytes,
  });

  final ReverseEmotionStyle style;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final TensionLevel tension;
  final String dogText;
  final String explanation;
  final Uint8List audioBytes;
}

class DogProfile {
  const DogProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.notes,
    required this.createdAtIso,
  });

  final String id;
  final String name;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final String notes;
  final String createdAtIso;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed.name,
      'ageStage': ageStage.name,
      'sizeClass': sizeClass.name,
      'notes': notes,
      'createdAtIso': createdAtIso,
    };
  }

  factory DogProfile.fromJson(Map<String, dynamic> json) {
    return DogProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'プロフィール',
      breed: DogBreedText.fromKey(json['breed'] as String?),
      ageStage: DogAgeStageText.fromKey(json['ageStage'] as String?),
      sizeClass: DogSizeClassText.fromKey(json['sizeClass'] as String?),
      notes: json['notes'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String? ?? '',
    );
  }
}

class ForwardRecord {
  const ForwardRecord({
    required this.id,
    required this.timestampIso,
    required this.profileId,
    required this.sceneMode,
    required this.translation,
    required this.recordingPath,
    required this.feedbackLabel,
  });

  final String id;
  final String timestampIso;
  final String? profileId;
  final SceneMode sceneMode;
  final TranslationResult translation;
  final String? recordingPath;
  final UserFeedbackLabel? feedbackLabel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestampIso': timestampIso,
      'profileId': profileId,
      'sceneMode': sceneMode.name,
      'translation': translation.toJson(),
      'recordingPath': recordingPath,
      'feedbackLabel': feedbackLabel?.name,
    };
  }

  factory ForwardRecord.fromJson(Map<String, dynamic> json) {
    return ForwardRecord(
      id: json['id'] as String? ?? '',
      timestampIso: json['timestampIso'] as String? ?? '',
      profileId: json['profileId'] as String?,
      sceneMode: SceneModeText.fromKey(json['sceneMode'] as String?),
      translation: TranslationResult.fromJson(
        (json['translation'] as Map<dynamic, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
      recordingPath: json['recordingPath'] as String?,
      feedbackLabel: json['feedbackLabel'] == null
          ? null
          : UserFeedbackLabelText.fromKey(json['feedbackLabel'] as String?),
    );
  }
}

class ReverseRecord {
  const ReverseRecord({
    required this.id,
    required this.timestampIso,
    required this.profileId,
    required this.sceneMode,
    required this.style,
    required this.breed,
    required this.ageStage,
    required this.sizeClass,
    required this.tension,
    required this.dogText,
    required this.explanation,
  });

  final String id;
  final String timestampIso;
  final String? profileId;
  final SceneMode sceneMode;
  final ReverseEmotionStyle style;
  final DogBreed breed;
  final DogAgeStage ageStage;
  final DogSizeClass sizeClass;
  final TensionLevel tension;
  final String dogText;
  final String explanation;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestampIso': timestampIso,
      'profileId': profileId,
      'sceneMode': sceneMode.name,
      'style': style.name,
      'breed': breed.name,
      'ageStage': ageStage.name,
      'sizeClass': sizeClass.name,
      'tension': tension.name,
      'dogText': dogText,
      'explanation': explanation,
    };
  }

  factory ReverseRecord.fromJson(Map<String, dynamic> json) {
    return ReverseRecord(
      id: json['id'] as String? ?? '',
      timestampIso: json['timestampIso'] as String? ?? '',
      profileId: json['profileId'] as String?,
      sceneMode: SceneModeText.fromKey(json['sceneMode'] as String?),
      style: ReverseEmotionStyle.values.firstWhere(
        (value) => value.name == json['style'],
        orElse: () => ReverseEmotionStyle.neutral,
      ),
      breed: DogBreedText.fromKey(json['breed'] as String?),
      ageStage: DogAgeStageText.fromKey(json['ageStage'] as String?),
      sizeClass: DogSizeClassText.fromKey(json['sizeClass'] as String?),
      tension: TensionLevelText.fromKey(json['tension'] as String?),
      dogText: json['dogText'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.selectedProfileId,
    required this.selectedInputDeviceId,
    required this.selectedBreed,
    required this.selectedAgeStage,
    required this.selectedSizeClass,
    required this.selectedTension,
    required this.selectedSceneMode,
  });

  final String? selectedProfileId;
  final String? selectedInputDeviceId;
  final DogBreed selectedBreed;
  final DogAgeStage selectedAgeStage;
  final DogSizeClass selectedSizeClass;
  final TensionLevel selectedTension;
  final SceneMode selectedSceneMode;

  Map<String, dynamic> toJson() {
    return {
      'selectedProfileId': selectedProfileId,
      'selectedInputDeviceId': selectedInputDeviceId,
      'selectedBreed': selectedBreed.name,
      'selectedAgeStage': selectedAgeStage.name,
      'selectedSizeClass': selectedSizeClass.name,
      'selectedTension': selectedTension.name,
      'selectedSceneMode': selectedSceneMode.name,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      selectedProfileId: json['selectedProfileId'] as String?,
      selectedInputDeviceId: json['selectedInputDeviceId'] as String?,
      selectedBreed: DogBreedText.fromKey(json['selectedBreed'] as String?),
      selectedAgeStage: DogAgeStageText.fromKey(
        json['selectedAgeStage'] as String?,
      ),
      selectedSizeClass: DogSizeClassText.fromKey(
        json['selectedSizeClass'] as String?,
      ),
      selectedTension: TensionLevelText.fromKey(
        json['selectedTension'] as String?,
      ),
      selectedSceneMode: SceneModeText.fromKey(
        json['selectedSceneMode'] as String?,
      ),
    );
  }

  static const defaults = AppSettings(
    selectedProfileId: null,
    selectedInputDeviceId: null,
    selectedBreed: DogBreed.mixed,
    selectedAgeStage: DogAgeStage.adult,
    selectedSizeClass: DogSizeClass.medium,
    selectedTension: TensionLevel.normal,
    selectedSceneMode: SceneMode.home,
  );
}

class AppData {
  const AppData({
    required this.profiles,
    required this.forwardRecords,
    required this.reverseRecords,
    required this.settings,
  });

  final List<DogProfile> profiles;
  final List<ForwardRecord> forwardRecords;
  final List<ReverseRecord> reverseRecords;
  final AppSettings settings;

  Map<String, dynamic> toJson() {
    return {
      'profiles': profiles.map((value) => value.toJson()).toList(),
      'forwardRecords': forwardRecords.map((value) => value.toJson()).toList(),
      'reverseRecords': reverseRecords.map((value) => value.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    final profilesJson = json['profiles'] as List<dynamic>? ?? const [];
    final forwardJson = json['forwardRecords'] as List<dynamic>? ?? const [];
    final reverseJson = json['reverseRecords'] as List<dynamic>? ?? const [];

    return AppData(
      profiles: profilesJson
          .map(
            (value) => DogProfile.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      forwardRecords: forwardJson
          .map(
            (value) => ForwardRecord.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      reverseRecords: reverseJson
          .map(
            (value) => ReverseRecord.fromJson(
              (value as Map<dynamic, dynamic>).cast<String, dynamic>(),
            ),
          )
          .toList(growable: false),
      settings: AppSettings.fromJson(
        (json['settings'] as Map<dynamic, dynamic>? ?? const {})
            .cast<String, dynamic>(),
      ),
    );
  }

  static const empty = AppData(
    profiles: <DogProfile>[],
    forwardRecords: <ForwardRecord>[],
    reverseRecords: <ReverseRecord>[],
    settings: AppSettings.defaults,
  );
}

enum InteractionMode { forward, reverse }

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isPersisted,
  });

  final String id;
  final InteractionMode mode;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isPersisted;
}

class RecordingInputDevice {
  const RecordingInputDevice({required this.id, required this.label});

  final String id;
  final String label;
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalForward,
    required this.totalReverse,
    required this.feedbackCount,
    required this.intentCounts,
    required this.sceneCounts,
    required this.profileCounts,
  });

  final int totalForward;
  final int totalReverse;
  final int feedbackCount;
  final Map<String, int> intentCounts;
  final Map<String, int> sceneCounts;
  final Map<String, int> profileCounts;
}
