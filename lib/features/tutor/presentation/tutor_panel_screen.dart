import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
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
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> justifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel del tutor')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF0D5), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFFFFF8E1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resumen',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary)),
                          const SizedBox(height: 6),
                          Text('Grupo: ${summary['code'] ?? 'N/A'}'),
                          Text('Estudiantes: ${summary['students'] ?? 0}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: const Color(0xFFE3F2FD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grupos y alumnos',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                          const SizedBox(height: 8),
                          ..._buildGroupList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildJustificationChart(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Alertas automáticas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  ...alerts.map((a) => Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text(a.message),
                          subtitle: Text(a.type),
                        ),
                      )),
                ],
              ),
      ),
    );
  }

  Future<void> _load() async {
    final token = ref.read(sessionProvider).session?.token;
    final repo = TutorRepository(ApiClient(token: token));
    final alertData = await repo.fetchAlerts();
    final panel = await repo.fetchPanel();
    final grp = await repo.fetchGroups();
    final justs = await repo.fetchTutorJustifications();
    setState(() {
      alerts = alertData;
      summary = panel;
      groups = grp;
      justifications = justs;
      loading = false;
    });
  }

  List<Widget> _buildGroupList() {
    if (groups.isEmpty) {
      return [const Text('Sin grupos aún')];
    }
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in groups) {
      grouped.putIfAbsent(row['code'] as String, () => []).add(row);
    }
    return grouped.entries.map((entry) {
      final students = entry.value.where((e) => e['studentId'] != null).toList();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.key} (${entry.value.first['term']})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (students.isEmpty)
              const Text('Sin alumnos aún')
            else
              ...students.map((s) => Text('- ${s['name'] ?? s['email']}')),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildJustificationChart() {
    final counts = {'pendiente': 0, 'aprobado': 0, 'rechazado': 0};
    for (final j in justifications) {
      final status = (j['status'] as String?) ?? 'pendiente';
      if (counts.containsKey(status)) counts[status] = counts[status]! + 1;
    }
    final total = counts.values.fold<int>(0, (p, e) => p + e);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Justificantes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 6),
        Row(
          children: counts.entries.map((e) {
            final pct = total == 0 ? 0 : (e.value / total * 100).round();
            Color color;
            switch (e.key) {
              case 'aprobado':
                color = Colors.green.shade400;
                break;
              case 'rechazado':
                color = Colors.red.shade300;
                break;
              default:
                color = Colors.orange.shade300;
            }
            return Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${e.key}: ${e.value} (${pct}%)'),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
