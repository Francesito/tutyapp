import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';
import '../../auth/providers/session_provider.dart';

class PerceptionScreen extends ConsumerStatefulWidget {
  const PerceptionScreen({super.key});

  @override
  ConsumerState<PerceptionScreen> createState() => _PerceptionScreenState();
}

class _PerceptionScreenState extends ConsumerState<PerceptionScreen> {
  final _subject = TextEditingController();
  String? _perception;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Percepción semanal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subject,
              decoration: const InputDecoration(labelText: 'Asignatura'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: PerceptionOptions.options
                  .map((option) => ChoiceChip(
                        label: Text(option),
                        selected: _perception == option,
                        onSelected: (_) => setState(() => _perception = option),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _perception == null ? null : _submit,
              child: const Text('Guardar percepción'),
            ),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_status),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    try {
      final token = ref.read(sessionProvider).session?.token;
      final repo = StudentRepository(ApiClient(token: token));
      await repo.submitPerception(_subject.text, _perception!);
      setState(() => _status = 'Guardado');
    } catch (e) {
      setState(() => _status = 'No se pudo guardar');
    }
  }
}
