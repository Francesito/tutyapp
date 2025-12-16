import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/api_client.dart';
import '../../auth/providers/session_provider.dart';
import '../domain/tutor_repository.dart';

class TutorReportsScreen extends ConsumerWidget {
  const TutorReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(sessionProvider).session?.token;
    final repo = TutorRepository(ApiClient(token: token));
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exportar', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _open(repo.reportPdfUrl()),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar PDF'),
            ),
            FilledButton.icon(
              onPressed: () => _open(repo.reportExcelUrl()),
              icon: const Icon(Icons.table_view),
              label: const Text('Generar Excel (CSV)'),
            ),
            const SizedBox(height: 16),
            const Text('Los archivos se generan con datos actuales y pueden compartirse.'),
          ],
        ),
      ),
    );
  }

  Future<void> _open(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
