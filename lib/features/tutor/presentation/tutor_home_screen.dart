import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/session_provider.dart';

class TutorHomeScreen extends ConsumerWidget {
  const TutorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Tutor'),
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
            colors: [Color(0xFF0D47A1), Color(0xFF82B1FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _card(
                context,
                title: 'Panel',
                subtitle: 'Ánimo, alertas y resumen',
                onTap: () => context.go('/tutor/panel'),
              ),
              _card(
                context,
                title: 'Crear grupo',
                subtitle: 'Código único por cuatrimestre',
                onTap: () => context.go('/tutor/groups/create'),
              ),
              _card(
                context,
                title: 'Justificantes',
                subtitle: 'Aprobar / rechazar',
                onTap: () => context.go('/tutor/justifications'),
              ),
              _card(
                context,
                title: 'Reportes',
                subtitle: 'Exportar PDF/Excel',
                onTap: () => context.go('/tutor/reports'),
              ),
              if (session != null)
                _card(
                  context,
                  title: 'Perfil',
                  subtitle: session.email,
                  onTap: () {},
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context,
      {required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return SizedBox(
      width: 200,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
