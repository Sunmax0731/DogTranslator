import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({
    required this.forwardRecords,
    required this.reverseRecords,
    required this.compareSelection,
    required this.onToggleCompare,
    super.key,
  });

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
