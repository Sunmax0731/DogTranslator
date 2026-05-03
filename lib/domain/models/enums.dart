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
        return '短く勢いのある鳴き方が多く、遊びや歓迎の気分が強そうです。';
      case DogIntent.attentionSeeking:
        return '呼びかけるようなリズムがあり、こちらに気づいてほしい様子です。';
      case DogIntent.warningAlert:
        return '音量や鋭さが強く、警戒や周囲への反応が出ていそうです。';
      case DogIntent.anxiousWhine:
        return '長めで弱い鳴き方が多く、不安や甘えの傾向がありそうです。';
      case DogIntent.sleepy:
        return '弱く穏やかな音が中心で、眠そうな雰囲気に見えます。';
      case DogIntent.restlessEnergy:
        return '落ち着きのない変化があり、そわそわした状態かもしれません。';
      case DogIntent.happyRelaxed:
        return '荒さが少なく、機嫌よく落ち着いている可能性があります。';
      case DogIntent.bored:
        return '刺激が足りず、退屈している時のパターンに近いです。';
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

enum RecordingQualityIssue { tooShort, lowVolume, peakyInput, unstableNoise }

extension RecordingQualityIssueText on RecordingQualityIssue {
  String get labelJa {
    switch (this) {
      case RecordingQualityIssue.tooShort:
        return '録音が短すぎます';
      case RecordingQualityIssue.lowVolume:
        return '音量が小さめです';
      case RecordingQualityIssue.peakyInput:
        return '一瞬だけ大きな音が入っています';
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
        return '突然の物音を避けて、犬の声が中心になるよう録音してください。';
      case RecordingQualityIssue.unstableNoise:
        return 'テレビや換気音が少ない環境で録音してください。';
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
        return '標準的でバランスの良い鳴き方を想定しています。';
      case DogBreed.shiba:
        return 'やや張りのある、切れの良い鳴き方を意識した表現です。';
      case DogBreed.chihuahua:
        return '高めで細かいテンポの鳴き方を意識した表現です。';
      case DogBreed.toyPoodle:
        return '軽快で明るい鳴き方を意識した表現です。';
      case DogBreed.goldenRetriever:
        return '柔らかく厚みのある鳴き方を意識した表現です。';
      case DogBreed.husky:
        return '遠吠え寄りの伸びを少し加えた表現です。';
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
