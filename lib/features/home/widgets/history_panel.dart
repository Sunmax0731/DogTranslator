import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class HistoryPanel extends StatefulWidget {
  const HistoryPanel({
    required this.forwardRecords,
    required this.profileNameById,
    required this.compareSelection,
    required this.onToggleCompare,
    required this.onPlayForwardRecord,
    super.key,
  });

  final List<ForwardRecord> forwardRecords;
  final Map<String, String> profileNameById;
  final Set<String> compareSelection;
  final ValueChanged<String> onToggleCompare;
  final ValueChanged<String> onPlayForwardRecord;

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.forwardRecords
        .where((record) {
          if (_query.isEmpty) {
            return true;
          }
          final profileName = widget.profileNameById[record.profileId] ?? '';
          final haystack = [
            record.translation.intent.labelJa,
            record.translation.explanation,
            record.sceneMode.labelJa,
            profileName,
          ].join(' ').toLowerCase();
          return haystack.contains(_query.toLowerCase());
        })
        .toList(growable: false);

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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '履歴を検索',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                });
              },
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Expanded(child: Center(child: Text('履歴がありません。')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final record = items[index];
                    final timestamp =
                        DateTime.tryParse(record.timestampIso) ??
                        DateTime.now();
                    final profileName =
                        widget.profileNameById[record.profileId] ?? '未設定';
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onPlayForwardRecord(record.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFCCFBF1),
                              foregroundColor: Color(0xFF134E4A),
                              child: Icon(Icons.pets),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.translation.intent.labelJa,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$profileName / ${record.sceneMode.labelJa}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record.translation.explanation,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatTimestamp(timestamp),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => widget
                                            .onPlayForwardRecord(record.id),
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('再生'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            widget.onToggleCompare(record.id),
                                        icon: Icon(
                                          widget.compareSelection.contains(
                                                record.id,
                                              )
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                        ),
                                        label: const Text('比較に追加'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
    final y = time.year.toString().padLeft(4, '0');
    final mo = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $hh:$mm:$ss';
  }
}
