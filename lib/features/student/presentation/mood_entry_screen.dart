import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';
import '../../auth/providers/session_provider.dart';

class MoodEntryScreen extends ConsumerStatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  ConsumerState<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends ConsumerState<MoodEntryScreen> {
  String? _selected;
  final _note = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro diario de ánimo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: MoodOptions.emojis
                  .map(
                    (emoji) => ChoiceChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 20)),
                      selected: _selected == emoji,
                      onSelected: (_) => setState(() => _selected = emoji),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Nota opcional',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _selected == null ? null : _submit,
              child: const Text('Registrar'),
            ),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_status),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    try {
      final token = ref.read(sessionProvider).session?.token;
      final repo = StudentRepository(ApiClient(token: token));
      await repo.submitMood(_selected!, _note.text);
      setState(() => _status = 'Ánimo registrado');
    } catch (e) {
      setState(() => _status = 'No se pudo guardar');
    }
  }
}
