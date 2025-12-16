import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models.dart';
import '../../auth/domain/auth_repository.dart';
import '../providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(AppText.appName,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _loading ? null : _onLogin,
                    child: _loading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Iniciar sesión'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Crear cuenta'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = AuthRepository();
      final session = await repo.login(
        _emailController.text,
        _passwordController.text,
      );
      ref.read(sessionProvider).setSession(session);
      if (session.role == UserRole.tutor) {
        if (mounted) context.go('/tutor');
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() => _error = 'Credenciales inválidas o error de red');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
