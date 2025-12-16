import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {'from': 'Tutor', 'text': 'Recuerden enviar percepción semanal'},
      {'from': 'Alumno', 'text': 'Listo, profe'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(msg['text']!),
                  subtitle: Text(msg['from']!),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Chat 1:1 y grupal vendría aquí'),
          )
        ],
      ),
    );
  }
}
