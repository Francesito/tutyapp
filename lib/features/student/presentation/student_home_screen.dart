import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';
import '../../auth/providers/session_provider.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  final _codeController = TextEditingController();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Alumno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(sessionProvider).logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF0D5), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👋 Hola, ${session?.name ?? session?.email ?? ''}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Código de grupo'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              hintText: 'SP01SV-24',
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _joinGroup,
                          child: const Text('Unirse'),
                        ),
                      ],
                    ),
                    if (_status.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_status),
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _FeatureCard(
                  title: 'Ánimo diario 😊',
                  icon: Icons.emoji_emotions,
                  onTap: () => context.go('/home/mood'),
                  color: const Color(0xFFFFD54F),
                ),
                _FeatureCard(
                  title: 'Percepciones 📚',
                  icon: Icons.school,
                  onTap: () => context.go('/home/perception'),
                  color: const Color(0xFF80DEEA),
                ),
                _FeatureCard(
                  title: 'Justificantes 📝',
                  icon: Icons.description,
                  onTap: () => context.go('/home/justifications'),
                  color: const Color(0xFFA5D6A7),
                ),
                _FeatureCard(
                  title: 'Historial 📜',
                  icon: Icons.history,
                  onTap: () => context.go('/home/history'),
                  color: const Color(0xFFCE93D8),
                ),
                _FeatureCard(
                  title: 'Mensajes 💬',
                  icon: Icons.chat,
                  onTap: () => context.go('/home/chat'),
                  color: const Color(0xFF90CAF9),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _joinGroup() async {
    setState(() => _status = '');
    try {
      final token = ref.read(sessionProvider).session?.token;
      final repo = StudentRepository(ApiClient(token: token));
      await repo.joinGroup(_codeController.text);
      setState(() => _status = 'Te uniste al grupo');
    } catch (e) {
      setState(() => _status = 'No se pudo unir al grupo');
    }
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 30, color: Colors.black87),
                  const SizedBox(height: 8),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
