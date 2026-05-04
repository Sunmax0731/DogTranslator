import 'package:dog_translator/domain/models.dart';
import 'package:dog_translator/features/home/widgets/feature_chip.dart';
import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({
    required this.analyticsSummary,
    required this.comparisonRecords,
    required this.profiles,
    required this.forwardRecords,
    required this.selectedProfileFilterId,
    required this.onProfileFilterChanged,
    required this.onIntentEntrySelected,
    super.key,
  });

  final AnalyticsSummary analyticsSummary;
  final List<ForwardRecord> comparisonRecords;
  final List<DogProfile> profiles;
  final List<ForwardRecord> forwardRecords;
  final String? selectedProfileFilterId;
  final ValueChanged<String?> onProfileFilterChanged;
  final ValueChanged<String> onIntentEntrySelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: selectedProfileFilterId,
                    decoration: const InputDecoration(
                      labelText: 'ダッシュボード対象プロフィール',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('全プロフィール'),
                      ),
                      ...profiles.map(
                        (profile) => DropdownMenuItem<String?>(
                          value: profile.id,
                          child: Text(profile.name),
                        ),
                      ),
                    ],
                    onChanged: onProfileFilterChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FeatureChip(
              label: 'Forward 件数',
              value: analyticsSummary.totalForward.toString(),
            ),
            FeatureChip(
              label: 'フィードバック数',
              value: analyticsSummary.feedbackCount.toString(),
            ),
            FeatureChip(label: 'プロフィール数', value: profiles.length.toString()),
          ],
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          title: '感情推定',
          emptyText: 'まだ forward 解析結果がありません。',
          entries: analyticsSummary.intentCounts,
          onEntryTap: onIntentEntrySelected,
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          title: 'シーン別',
          emptyText: 'まだシーン付きの履歴がありません。',
          entries: analyticsSummary.sceneCounts,
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
                  const Text('履歴から forward 解析を 2 件選ぶと比較できます。')
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
                  '最新の forward 履歴',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.emptyText,
    required this.entries,
    this.onEntryTap,
  });

  final String title;
  final String emptyText;
  final Map<String, int> entries;
  final ValueChanged<String>? onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(emptyText)
            else
              ...entries.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: onEntryTap == null
                        ? null
                        : () => onEntryTap!(entry.key),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text(entry.value.toString()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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
