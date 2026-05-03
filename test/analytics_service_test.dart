import 'package:dog_translator/domain/analytics_service.dart';
import 'package:dog_translator/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summarizes profile, intent, and feedback counts', () {
    const profile = DogProfile(
      id: 'p1',
      name: 'Komugi',
      breed: DogBreed.shiba,
      ageStage: DogAgeStage.adult,
      sizeClass: DogSizeClass.medium,
      notes: '',
      createdAtIso: '2026-05-04T00:00:00.000',
    );

    const translation = TranslationResult(
      intent: DogIntent.attentionSeeking,
      explanation: 'test',
      confidence: ConfidenceLevel.medium,
      features: AudioFeatures(
        durationSeconds: 1,
        rms: 0.1,
        peak: 0.2,
        zeroCrossingRate: 0.1,
        burstCount: 2,
        dynamicRange: 0.1,
        spectralCentroid: 800,
        highBandRatio: 0.2,
      ),
      candidates: <TranslationCandidate>[
        TranslationCandidate(intent: DogIntent.attentionSeeking, score: 0.6),
      ],
      qualityIssues: <RecordingQualityIssue>[],
    );

    final summary = const AnalyticsService().summarize(
      const <ForwardRecord>[
        ForwardRecord(
          id: 'f1',
          timestampIso: '2026-05-04T01:00:00.000',
          profileId: 'p1',
          sceneMode: SceneMode.playtime,
          translation: translation,
          recordingPath: null,
          feedbackLabel: UserFeedbackLabel.matched,
        ),
      ],
      const <ReverseRecord>[
        ReverseRecord(
          id: 'r1',
          timestampIso: '2026-05-04T02:00:00.000',
          profileId: 'p1',
          sceneMode: SceneMode.home,
          style: ReverseEmotionStyle.friendly,
          breed: DogBreed.shiba,
          ageStage: DogAgeStage.adult,
          sizeClass: DogSizeClass.medium,
          tension: TensionLevel.normal,
          dogText: 'wan',
          explanation: 'test',
        ),
      ],
      const <DogProfile>[profile],
    );

    expect(summary.totalForward, 1);
    expect(summary.totalReverse, 1);
    expect(summary.feedbackCount, 1);
    expect(summary.intentCounts['かまってほしい'], 1);
    expect(summary.profileCounts['Komugi'], 2);
  });
}
