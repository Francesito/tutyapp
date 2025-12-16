import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/session_provider.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.tutorGroupCode});

  final String? tutorGroupCode;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageCtrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).session;
    return Scaffold(
      appBar: AppBar(title: const Text('Chat grupal')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFDF0D5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMine = msg['email'] == session?.email;
                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMine ? Colors.lightBlue.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(msg['name'] ?? msg['email'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(msg['message'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje para todos...',
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: Colors.blue),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    final session = ref.read(sessionProvider).session;
    _messageCtrl.clear();
    final token = session?.token;
    final repo = StudentRepository(ApiClient(token: token));
    repo.sendChatMessage(text, groupCode: widget.tutorGroupCode);
    _load();
  }

  Future<void> _load() async {
    final token = ref.read(sessionProvider).session?.token;
    final repo = StudentRepository(ApiClient(token: token));
    final data = await repo.fetchChat(groupCode: widget.tutorGroupCode);
    setState(() {
      _messages = data;
      loading = false;
    });
  }
}
