import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api_client.dart';
import '../domain/tutor_repository.dart';
import '../../auth/providers/session_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _code = TextEditingController();
  final _term = TextEditingController(text: '2024Q2');
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear grupo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'Código (único)'),
            ),
            TextField(
              controller: _term,
              decoration: const InputDecoration(labelText: 'Cuatrimestre'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _create,
              child: const Text('Crear'),
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

  Future<void> _create() async {
    try {
      final token = ref.read(sessionProvider).session?.token;
      final repo = TutorRepository(ApiClient(token: token));
      await repo.createGroup(_code.text, _term.text);
      setState(() => _status = 'Grupo creado');
    } catch (e) {
      setState(() => _status = 'Error: código duplicado?');
    }
  }
}
