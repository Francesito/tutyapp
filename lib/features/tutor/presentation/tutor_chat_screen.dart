import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/api_client.dart';
import '../../auth/providers/session_provider.dart';
import '../domain/tutor_repository.dart';
import '../../student/domain/student_repository.dart';

class TutorChatScreen extends ConsumerStatefulWidget {
  const TutorChatScreen({super.key});

  @override
  ConsumerState<TutorChatScreen> createState() => _TutorChatScreenState();
}

class _TutorChatScreenState extends ConsumerState<TutorChatScreen> {
  final _messageCtrl = TextEditingController();
  String? _selectedGroup;
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedGroup,
                hint: const Text('Selecciona grupo'),
                items: groups
                    .map((g) => DropdownMenuItem<String>(
                          value: g['code'] as String,
                          child: Text('${g['code']} (${g['term']})'),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedGroup = v;
                    loading = true;
                  });
                  _loadMessages();
                },
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
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

  Future<void> _loadGroups() async {
    final token = ref.read(sessionProvider).session?.token;
    final tutorRepo = TutorRepository(ApiClient(token: token));
    final data = await tutorRepo.fetchGroups();
    setState(() {
      groups = data;
      _selectedGroup = data.isNotEmpty ? data.first['code'] as String : null;
    });
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_selectedGroup == null) {
      setState(() {
        messages = [];
        loading = false;
      });
      return;
    }
    final token = ref.read(sessionProvider).session?.token;
    final repo = StudentRepository(ApiClient(token: token));
    final data = await repo.fetchChat(groupCode: _selectedGroup);
    setState(() {
      messages = data;
      loading = false;
    });
  }

  Future<void> _send() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _selectedGroup == null) return;
    _messageCtrl.clear();
    final token = ref.read(sessionProvider).session?.token;
    final repo = StudentRepository(ApiClient(token: token));
    await repo.sendChatMessage(text, groupCode: _selectedGroup);
    await _loadMessages();
  }
}
