import 'package:flutter/material.dart';

class TutorReportsScreen extends StatelessWidget {
  const TutorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar PDF'),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.table_view),
              label: const Text('Generar Excel'),
            ),
            const SizedBox(height: 16),
            const Text('Instrucciones: los archivos se pueden enviar a coordinación.'),
          ],
        ),
      ),
    );
  }
}
