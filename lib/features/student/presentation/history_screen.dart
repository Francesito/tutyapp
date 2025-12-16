import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';
import '../../auth/providers/session_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<MoodEntry> moods = [];
  List<PerceptionEntry> perceptions = [];
  List<JustificationRequest> justifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Ánimo', style: TextStyle(fontWeight: FontWeight.bold)),
                ...moods.map((e) => ListTile(
                      leading: Text(e.emoji, style: const TextStyle(fontSize: 20)),
                      title: Text(e.note ?? ''),
                      subtitle: Text(e.date.toIso8601String().split('T').first),
                    )),
                const SizedBox(height: 12),
                const Text('Percepciones',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...perceptions.map((e) => ListTile(
                      title: Text(e.subject),
                      subtitle: Text(e.perception),
                    )),
                const SizedBox(height: 12),
                const Text('Justificantes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...justifications.map((j) => ListTile(
                      title: Text(j.reason),
                      subtitle: Text('Estado: ${j.status}'),
                      trailing: const Icon(Icons.receipt_long),
                    )),
              ],
            ),
    );
  }

  Future<void> _load() async {
    final token = ref.read(sessionProvider).session?.token;
    final repo = StudentRepository(ApiClient(token: token));
    try {
      final m = await repo.fetchMoodHistory();
      final p = await repo.fetchPerceptions();
      final j = await repo.fetchJustifications();
      setState(() {
        moods = m;
        perceptions = p;
        justifications = j;
      });
    } finally {
      setState(() => loading = false);
    }
  }
}
