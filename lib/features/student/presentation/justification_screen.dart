import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';
import '../../auth/providers/session_provider.dart';

class JustificationScreen extends ConsumerStatefulWidget {
  const JustificationScreen({super.key});

  @override
  ConsumerState<JustificationScreen> createState() => _JustificationScreenState();
}

class _JustificationScreenState extends ConsumerState<JustificationScreen> {
  final _reason = TextEditingController();
  final _evidence = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar justificante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _reason,
              decoration: const InputDecoration(labelText: 'Motivo'),
            ),
            TextField(
              controller: _evidence,
              decoration: const InputDecoration(labelText: 'URL de evidencia'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submit,
              child: const Text('Enviar (máx 2 por cuatrimestre)'),
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
      await repo.submitJustification(_reason.text, _evidence.text);
      setState(() => _status = 'Enviado');
    } catch (e) {
      setState(() => _status = 'Límite alcanzado o error');
    }
  }
}
