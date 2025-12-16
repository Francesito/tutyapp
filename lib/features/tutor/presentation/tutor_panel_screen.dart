import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models.dart';
import '../../../data/api_client.dart';
import '../domain/tutor_repository.dart';
import '../../auth/providers/session_provider.dart';

class TutorPanelScreen extends ConsumerStatefulWidget {
  const TutorPanelScreen({super.key});

  @override
  ConsumerState<TutorPanelScreen> createState() => _TutorPanelScreenState();
}

class _TutorPanelScreenState extends ConsumerState<TutorPanelScreen> {
  bool loading = true;
  List<AlertItem> alerts = [];
  Map<String, dynamic> summary = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel del tutor')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Resumen grupo: ${summary['group'] ?? 'N/A'}'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Alertas automáticas',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...alerts.map((a) => ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(a.message),
                      subtitle: Text(a.type),
                    )),
              ],
            ),
    );
  }

  Future<void> _load() async {
    final token = ref.read(sessionProvider).session?.token;
    final repo = TutorRepository(ApiClient(token: token));
    final alertData = await repo.fetchAlerts();
    final panel = await repo.fetchPanel();
    setState(() {
      alerts = alertData;
      summary = panel;
      loading = false;
    });
  }
}
