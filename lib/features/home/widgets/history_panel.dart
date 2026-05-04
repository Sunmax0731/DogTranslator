import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({
    required this.forwardRecords,
    required this.profileNameById,
    required this.compareSelection,
    required this.searchQuery,
    required this.selectedIntentLabel,
    required this.selectedProfileFilterId,
    required this.availableIntentLabels,
    required this.availableProfileFilters,
    required this.onSearchChanged,
    required this.onIntentFilterChanged,
    required this.onProfileFilterChanged,
    required this.onClearFilters,
    required this.onToggleCompare,
    required this.onSelectForwardRecord,
    required this.onPlayForwardRecord,
    required this.onDeleteForwardRecord,
    required this.onDeleteAllForwardRecords,
    super.key,
  });

  final List<ForwardRecord> forwardRecords;
  final Map<String, String> profileNameById;
  final Set<String> compareSelection;
  final String searchQuery;
  final String? selectedIntentLabel;
  final String? selectedProfileFilterId;
  final List<String> availableIntentLabels;
  final List<MapEntry<String, String>> availableProfileFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onIntentFilterChanged;
  final ValueChanged<String?> onProfileFilterChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onToggleCompare;
  final ValueChanged<String> onSelectForwardRecord;
  final ValueChanged<String> onPlayForwardRecord;
  final ValueChanged<String> onDeleteForwardRecord;
  final VoidCallback onDeleteAllForwardRecords;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Session History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'すべて削除',
                  onPressed: forwardRecords.isEmpty
                      ? null
                      : () => _confirmDeleteAll(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: searchQuery)
                ..selection = TextSelection.collapsed(
                  offset: searchQuery.length,
                ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: '履歴を検索',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InputChip(
                  label: const Text('フィルタ解除'),
                  onPressed: onClearFilters,
                ),
                ...availableIntentLabels.map(
                  (label) => FilterChip(
                    label: Text(label),
                    selected: selectedIntentLabel == label,
                    onSelected: (_) => onIntentFilterChanged(
                      selectedIntentLabel == label ? null : label,
                    ),
                  ),
                ),
                ...availableProfileFilters.map(
                  (entry) => FilterChip(
                    label: Text(entry.value),
                    selected: selectedProfileFilterId == entry.key,
                    onSelected: (_) => onProfileFilterChanged(
                      selectedProfileFilterId == entry.key ? null : entry.key,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (forwardRecords.isEmpty)
              const Expanded(child: Center(child: Text('履歴がありません。')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: forwardRecords.length,
                  separatorBuilder: (_, _) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final record = forwardRecords[index];
                    final timestamp =
                        DateTime.tryParse(record.timestampIso) ??
                        DateTime.now();
                    final profileName =
                        profileNameById[record.profileId] ?? '未設定';
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelectForwardRecord(record.id),
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
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        '$profileName / ${record.sceneMode.labelJa}',
                                      ),
                                      ActionChip(
                                        label: Text(
                                          record.translation.intent.labelJa,
                                        ),
                                        onPressed: () => onIntentFilterChanged(
                                          record.translation.intent.labelJa,
                                        ),
                                      ),
                                    ],
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
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            onPlayForwardRecord(record.id),
                                        icon: const Icon(Icons.play_arrow),
                                        label: const Text('再生'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            onToggleCompare(record.id),
                                        icon: Icon(
                                          compareSelection.contains(record.id)
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                        ),
                                        label: const Text('比較に追加'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _confirmDeleteOne(
                                          context,
                                          record.id,
                                        ),
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('削除'),
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

  Future<void> _confirmDeleteOne(BuildContext context, String id) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('履歴を削除'),
        content: const Text('この履歴を削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (approved == true) {
      onDeleteForwardRecord(id);
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('履歴をすべて削除'),
        content: const Text('Session History の履歴をすべて削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('すべて削除'),
          ),
        ],
      ),
    );
    if (approved == true) {
      onDeleteAllForwardRecords();
    }
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
