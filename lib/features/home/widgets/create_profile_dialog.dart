import 'package:dog_translator/domain/models.dart';
import 'package:flutter/material.dart';

class CreateProfileDialog extends StatefulWidget {
  const CreateProfileDialog({super.key});

  @override
  State<CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<CreateProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DogBreed _breed = DogBreed.mixed;
  DogAgeStage _ageStage = DogAgeStage.adult;
  DogSizeClass _sizeClass = DogSizeClass.medium;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プロフィール追加'),
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
              decoration: const InputDecoration(labelText: '年齢感'),
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
            Navigator.of(context).pop(
              DogProfile(
                id: 'profile-${DateTime.now().microsecondsSinceEpoch}',
                name: name,
                breed: _breed,
                ageStage: _ageStage,
                sizeClass: _sizeClass,
                notes: _notesController.text.trim(),
                createdAtIso: DateTime.now().toIso8601String(),
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
