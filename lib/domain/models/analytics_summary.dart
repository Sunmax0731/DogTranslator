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

  static const empty = AnalyticsSummary(
    totalForward: 0,
    totalReverse: 0,
    feedbackCount: 0,
    intentCounts: <String, int>{},
    sceneCounts: <String, int>{},
    profileCounts: <String, int>{},
  );
}
