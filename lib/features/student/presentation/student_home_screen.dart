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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, ${session?.name ?? session?.email ?? ''}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Código de grupo'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            hintText: 'SP01SV-24',
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
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureCard(
                title: 'Ánimo diario',
                icon: Icons.emoji_emotions,
                onTap: () => context.go('/home/mood'),
              ),
              _FeatureCard(
                title: 'Percepciones',
                icon: Icons.school,
                onTap: () => context.go('/home/perception'),
              ),
              _FeatureCard(
                title: 'Justificantes',
                icon: Icons.description,
                onTap: () => context.go('/home/justifications'),
              ),
              _FeatureCard(
                title: 'Historial',
                icon: Icons.history,
                onTap: () => context.go('/home/history'),
              ),
              _FeatureCard(
                title: 'Mensajes',
                icon: Icons.chat,
                onTap: () => context.go('/home/chat'),
              ),
            ],
          )
        ],
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
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
