import 'package:flutter/material.dart';

class TutorStudentDetailScreen extends StatelessWidget {
  const TutorStudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alumno $studentId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('Último ánimo: 🙂')),
          ListTile(title: Text('Faltas: 1')), 
          ListTile(title: Text('Promedio: 8.5')),
          ListTile(title: Text('Alertas: ninguna')),
        ],
      ),
    );
  }
}
