import 'package:flutter/material.dart';

class TutorJustificationsScreen extends StatefulWidget {
  const TutorJustificationsScreen({super.key});

  @override
  State<TutorJustificationsScreen> createState() => _TutorJustificationsScreenState();
}

class _TutorJustificationsScreenState extends State<TutorJustificationsScreen> {
  final items = [
    {'id': 1, 'student': 'Ana', 'reason': 'Médico', 'status': 'pendiente'},
    {'id': 2, 'student': 'Luis', 'reason': 'Viaje', 'status': 'pendiente'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de justificantes')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              title: Text('${item['student']} - ${item['reason']}'),
              subtitle: Text('Estado: ${item['status']}'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => setState(() => item['status'] = 'aprobado'),
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () => setState(() => item['status'] = 'rechazado'),
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
}
