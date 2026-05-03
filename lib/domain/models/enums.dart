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
        return 'うれしい / 落ち着いている';
      case DogIntent.bored:
        return '退屈している';
      case DogIntent.uncertain:
        return '判断が難しい';
    }
  }

  String get explanationJa {
    switch (this) {
      case DogIntent.excitedGreeting:
        return '短く元気な鳴き方が多く、遊びや歓迎の勢いがありそうです。';
      case DogIntent.attentionSeeking:
        return '呼びかけるようなリズムがあり、こちらに反応してほしい様子です。';
      case DogIntent.warningAlert:
        return '音量や緊張感が強く、警戒や見張りの反応が出ていそうです。';
      case DogIntent.anxiousWhine:
        return '長めで弱い鳴き方が多く、不安や甘えの傾向がありそうです。';
      case DogIntent.sleepy:
        return '眠そうな弱い声や小さな音量で、静かな状態に見えます。';
      case DogIntent.restlessEnergy:
        return '落ち着かない勢いがあり、そわそわした気分かもしれません。';
      case DogIntent.happyRelaxed:
        return '明るさがあり、安心して気分よく反応している可能性があります。';
      case DogIntent.bored:
        return '刺激が足りず、退屈している時間帯のパターンに近いです。';
      case DogIntent.uncertain:
        return '録音だけでは特徴が弱く、意図の特定が難しいです。';
    }
  }

  static DogIntent fromKey(String? key) {
    return DogIntent.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogIntent.uncertain,
    );
  }
}

enum DogVocalType { bark, growl, whine, howl, yelp, pant, mixed, unknown }

extension DogVocalTypeText on DogVocalType {
  String get labelJa {
    switch (this) {
      case DogVocalType.bark:
        return '吠え声';
      case DogVocalType.growl:
        return 'うなり声';
      case DogVocalType.whine:
        return '鼻鳴き';
      case DogVocalType.howl:
        return '遠吠え';
      case DogVocalType.yelp:
        return '高い短声';
      case DogVocalType.pant:
        return 'ハッハッという息音';
      case DogVocalType.mixed:
        return '混合的';
      case DogVocalType.unknown:
        return '不明';
    }
  }

  static DogVocalType fromKey(String? key) {
    return DogVocalType.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogVocalType.unknown,
    );
  }
}

enum DogContext {
  strangerOrNoise,
  ownerReturn,
  foodOrAttention,
  walkAnticipation,
  play,
  alone,
  otherDog,
  conflict,
  unknown,
}

extension DogContextText on DogContext {
  String get labelJa {
    switch (this) {
      case DogContext.strangerOrNoise:
        return '来客 / 物音';
      case DogContext.ownerReturn:
        return '飼い主の帰宅';
      case DogContext.foodOrAttention:
        return '食事 / 注目要求';
      case DogContext.walkAnticipation:
        return '散歩前の期待';
      case DogContext.play:
        return '遊び';
      case DogContext.alone:
        return 'ひとり / さみしさ';
      case DogContext.otherDog:
        return '他の犬への反応';
      case DogContext.conflict:
        return '緊張 / 競合';
      case DogContext.unknown:
        return '不明';
    }
  }

  static DogContext fromKey(String? key) {
    return DogContext.values.firstWhere(
      (value) => value.name == key,
      orElse: () => DogContext.unknown,
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
        return '音量が小さめです';
      case RecordingQualityIssue.peakyInput:
        return '瞬間的な大音量に偏っています';
      case RecordingQualityIssue.unstableNoise:
        return '雑音の影響が強そうです';
    }
  }

  String get adviceJa {
    switch (this) {
      case RecordingQualityIssue.tooShort:
        return 'もう少し長めに録音すると判断しやすくなります。';
      case RecordingQualityIssue.lowVolume:
        return 'マイクを近づけるか、静かな場所で録音してください。';
      case RecordingQualityIssue.peakyInput:
        return '大きな物音を避けて、声の区間が中心になるよう録音してください。';
      case RecordingQualityIssue.unstableNoise:
        return 'テレビや環境音が少ない場所で録音してください。';
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
        return '要求';
      case ReverseEmotionStyle.alert:
        return '警戒';
      case ReverseEmotionStyle.anxious:
        return '不安';
      case ReverseEmotionStyle.neutral:
        return 'ニュートラル';
    }
  }
}

enum AppThemePreset { defaultTeal, ocean, sunset, forest, graphite }

extension AppThemePresetText on AppThemePreset {
  String get labelJa {
    switch (this) {
      case AppThemePreset.defaultTeal:
        return 'Default';
      case AppThemePreset.ocean:
        return 'Ocean';
      case AppThemePreset.sunset:
        return 'Sunset';
      case AppThemePreset.forest:
        return 'Forest';
      case AppThemePreset.graphite:
        return 'Graphite';
    }
  }

  static AppThemePreset fromKey(String? key) {
    return AppThemePreset.values.firstWhere(
      (value) => value.name == key,
      orElse: () => AppThemePreset.defaultTeal,
    );
  }
}

enum DogBreed {
  mixed,
  shiba,
  chihuahua,
  toyPoodle,
  goldenRetriever,
  husky,
  pomeranian,
}

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
      case DogBreed.pomeranian:
        return 'ポメラニアン';
    }
  }

  String get descriptionJa {
    switch (this) {
      case DogBreed.mixed:
        return '標準的でバランスのよい鳴き声を想定した表現です。';
      case DogBreed.shiba:
        return 'やや張りのある、切れのよい鳴き声を想定した表現です。';
      case DogBreed.chihuahua:
        return '高めで軽いテンポの鳴き声を想定した表現です。';
      case DogBreed.toyPoodle:
        return '柔らかく明るい鳴き声を想定した表現です。';
      case DogBreed.goldenRetriever:
        return '広がりと厚みのある鳴き声を想定した表現です。';
      case DogBreed.husky:
        return '遠吠え寄りの響きを含む表現です。';
      case DogBreed.pomeranian:
        return '高めで軽快な反応を想定した表現です。';
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
        return '通常';
      case TensionLevel.excited:
        return '興奮気味';
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
        return '家の中';
      case SceneMode.playtime:
        return '遊び時間';
      case SceneMode.mealtime:
        return '食事前後';
      case SceneMode.walk:
        return '散歩';
      case SceneMode.guest:
        return '来客時';
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

enum InferenceModelSelection { auto, heuristic, dog2vecLocal }

extension InferenceModelSelectionText on InferenceModelSelection {
  String get labelJa {
    switch (this) {
      case InferenceModelSelection.auto:
        return '自動';
      case InferenceModelSelection.heuristic:
        return '標準ヒューリスティック';
      case InferenceModelSelection.dog2vecLocal:
        return 'Dog2vec ローカル';
    }
  }

  String get descriptionJa {
    switch (this) {
      case InferenceModelSelection.auto:
        return '利用可能なら Dog2vec ローカル推論を使い、使えない場合は標準推論に戻します。';
      case InferenceModelSelection.heuristic:
        return 'アプリ内の標準推論を使います。外部ランタイムは不要です。';
      case InferenceModelSelection.dog2vecLocal:
        return '外部の Dog2vec ローカル推論を優先して使います。未設定時は標準推論へ戻します。';
    }
  }

  static InferenceModelSelection fromKey(String? key) {
    return InferenceModelSelection.values.firstWhere(
      (value) => value.name == key,
      orElse: () => InferenceModelSelection.auto,
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
        return 'やや近い';
      case UserFeedbackLabel.off:
        return '外れている';
    }
  }

  static UserFeedbackLabel fromKey(String? key) {
    return UserFeedbackLabel.values.firstWhere(
      (value) => value.name == key,
      orElse: () => UserFeedbackLabel.close,
    );
  }
}
