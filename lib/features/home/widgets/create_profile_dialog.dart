import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class CreateProfileDialog extends StatelessWidget {
  const CreateProfileDialog({super.key})
    : initialProfile = null,
      title = 'プロフィール追加',
      confirmLabel = '追加';

  const CreateProfileDialog.edit({required this.initialProfile, super.key})
    : title = 'プロフィール編集',
      confirmLabel = '保存';

  final DogProfile? initialProfile;
  final String title;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return _ProfileEditorDialog(
      initialProfile: initialProfile,
      title: title,
      confirmLabel: confirmLabel,
    );
  }
}

class _ProfileEditorDialog extends StatefulWidget {
  const _ProfileEditorDialog({
    required this.initialProfile,
    required this.title,
    required this.confirmLabel,
  });

  final DogProfile? initialProfile;
  final String title;
  final String confirmLabel;

  @override
  State<_ProfileEditorDialog> createState() => _ProfileEditorDialogState();
}

class _ProfileEditorDialogState extends State<_ProfileEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late DogBreed _breed;
  late DogAgeStage _ageStage;
  late DogSizeClass _sizeClass;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _notesController = TextEditingController(text: profile?.notes ?? '');
    _breed = profile?.breed ?? DogBreed.mixed;
    _ageStage = profile?.ageStage ?? DogAgeStage.adult;
    _sizeClass = profile?.sizeClass ?? DogSizeClass.medium;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '名前'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogBreed>(
              initialValue: _breed,
              decoration: const InputDecoration(labelText: '犬種'),
              items: DogBreed.values
                  .map(
                    (value) => DropdownMenuItem<DogBreed>(
                      value: value,
                      child: Text(value.labelJa),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _breed = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogAgeStage>(
              initialValue: _ageStage,
              decoration: const InputDecoration(labelText: '年齢帯'),
              items: DogAgeStage.values
                  .map(
                    (value) => DropdownMenuItem<DogAgeStage>(
                      value: value,
                      child: Text(value.labelJa),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _ageStage = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DogSizeClass>(
              initialValue: _sizeClass,
              decoration: const InputDecoration(labelText: 'サイズ'),
              items: DogSizeClass.values
                  .map(
                    (value) => DropdownMenuItem<DogSizeClass>(
                      value: value,
                      child: Text(value.labelJa),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _sizeClass = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'メモ'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              return;
            }
            final current = widget.initialProfile;
            Navigator.of(context).pop(
              DogProfile(
                id:
                    current?.id ??
                    'profile-${DateTime.now().microsecondsSinceEpoch}',
                name: name,
                breed: _breed,
                ageStage: _ageStage,
                sizeClass: _sizeClass,
                notes: _notesController.text.trim(),
                createdAtIso:
                    current?.createdAtIso ?? DateTime.now().toIso8601String(),
                voiceCalibration: current?.voiceCalibration,
              ),
            );
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
