import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/api_client.dart';
import '../domain/tutor_repository.dart';
import '../../auth/providers/session_provider.dart';

class TutorJustificationsScreen extends ConsumerStatefulWidget {
  const TutorJustificationsScreen({super.key});

  @override
  ConsumerState<TutorJustificationsScreen> createState() => _TutorJustificationsScreenState();
}

class _TutorJustificationsScreenState extends ConsumerState<TutorJustificationsScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de justificantes')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('${item['studentName']} - ${item['reason']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grupo: ${item['groupCode'] ?? 'N/A'}'),
                        Text('Estado: ${item['status']}'),
                                if (item['evidenceUrl'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: Image.network(
                                            item['evidenceUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () => _downloadEvidence(item['evidenceUrl'] as String),
                                          child: const Text('Descargar'),
                                        )
                                      ],
                                    ),
                                  ),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          onPressed: () => _updateStatus(item['id'] as int, 'aprobado'),
                          icon: const Icon(Icons.check, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () => _updateStatus(item['id'] as int, 'rechazado'),
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _load() async {
    final token = ref.read(sessionProvider).session?.token;
    final repo = TutorRepository(ApiClient(token: token));
    final data = await repo.fetchTutorJustifications();
    setState(() {
      items = data;
      loading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    final token = ref.read(sessionProvider).session?.token;
    final repo = TutorRepository(ApiClient(token: token));
    await repo.updateJustification(id, status);
    await _load();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _downloadEvidence(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final savePath = '${dir.path}/$fileName';
      await Dio().download(url, savePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Descargado en $savePath')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo descargar')),
        );
      }
    }
  }
}
