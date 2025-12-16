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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F7FF), Color(0xFFE8F0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecciona tu ánimo de hoy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
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
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                decoration: const InputDecoration(
                  labelText: 'Nota opcional',
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _selected == null ? null : _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Registrar'),
              ),
              if (_status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_status),
                )
            ],
          ),
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
