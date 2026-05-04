import 'package:dog_translator/domain/models.dart';

class AnalyticsService {
  const AnalyticsService();

  AnalyticsSummary summarize(
    List<ForwardRecord> forwardRecords,
    List<ReverseRecord> reverseRecords,
    List<DogProfile> profiles, {
    String? profileFilterId,
  }) {
    final intentCounts = <String, int>{};
    final sceneCounts = <String, int>{};
    final profileCounts = <String, int>{};
    var feedbackCount = 0;

    final filteredForward = profileFilterId == null
        ? forwardRecords
        : forwardRecords
              .where((record) => record.profileId == profileFilterId)
              .toList(growable: false);
    final filteredReverse = profileFilterId == null
        ? reverseRecords
        : reverseRecords
              .where((record) => record.profileId == profileFilterId)
              .toList(growable: false);

    for (final record in filteredForward) {
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
        final label = _profileNameFor(record.profileId!, profiles);
        profileCounts.update(label, (value) => value + 1, ifAbsent: () => 1);
      }
      if (record.feedbackLabel != null) {
        feedbackCount++;
      }
    }

    for (final record in filteredReverse) {
      sceneCounts.update(
        record.sceneMode.labelJa,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      if (record.profileId != null && record.profileId!.isNotEmpty) {
        final label = _profileNameFor(record.profileId!, profiles);
        profileCounts.update(label, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return AnalyticsSummary(
      totalForward: filteredForward.length,
      totalReverse: filteredReverse.length,
      feedbackCount: feedbackCount,
      intentCounts: intentCounts,
      sceneCounts: sceneCounts,
      profileCounts: profileCounts,
    );
  }

  String _profileNameFor(String profileId, List<DogProfile> profiles) {
    for (final item in profiles) {
      if (item.id == profileId) {
        return item.name;
      }
    }
    return '未登録プロフィール';
  }
}
