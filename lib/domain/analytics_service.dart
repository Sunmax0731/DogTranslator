import 'package:dog_translator/domain/models.dart';

class AnalyticsService {
  const AnalyticsService();

  AnalyticsSummary summarize(
    List<ForwardRecord> forwardRecords,
    List<ReverseRecord> reverseRecords,
    List<DogProfile> profiles,
  ) {
    final intentCounts = <String, int>{};
    final sceneCounts = <String, int>{};
    final profileCounts = <String, int>{};
    var feedbackCount = 0;

    for (final record in forwardRecords) {
      intentCounts.update(
        record.translation.intent.labelJa,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      sceneCounts.update(
        record.sceneMode.labelJa,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      if (record.profileId != null && record.profileId!.isNotEmpty) {
        DogProfile? profile;
        for (final item in profiles) {
          if (item.id == record.profileId) {
            profile = item;
            break;
          }
        }
        final label = profile?.name ?? '不明プロフィール';
        profileCounts.update(label, (value) => value + 1, ifAbsent: () => 1);
      }
      if (record.feedbackLabel != null) {
        feedbackCount++;
      }
    }

    for (final record in reverseRecords) {
      sceneCounts.update(
        record.sceneMode.labelJa,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      if (record.profileId != null && record.profileId!.isNotEmpty) {
        DogProfile? profile;
        for (final item in profiles) {
          if (item.id == record.profileId) {
            profile = item;
            break;
          }
        }
        final label = profile?.name ?? '不明プロフィール';
        profileCounts.update(label, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return AnalyticsSummary(
      totalForward: forwardRecords.length,
      totalReverse: reverseRecords.length,
      feedbackCount: feedbackCount,
      intentCounts: intentCounts,
      sceneCounts: sceneCounts,
      profileCounts: profileCounts,
    );
  }
}
