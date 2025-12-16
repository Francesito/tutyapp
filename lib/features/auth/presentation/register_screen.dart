import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/models.dart';
import '../../auth/domain/auth_repository.dart';
import '../providers/session_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.student;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Registro')), 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Alumno'),
                          value: UserRole.student,
                          groupValue: _role,
                          onChanged: (v) => setState(() => _role = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<UserRole>(
                          title: const Text('Tutor'),
                          value: UserRole.tutor,
                          groupValue: _role,
                          onChanged: (v) => setState(() => _role = v!),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child:
                          Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  FilledButton(
                    onPressed: _loading ? null : _onRegister,
                    child: _loading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Crear cuenta'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = AuthRepository();
      final session = await repo.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
      );
      ref.read(sessionProvider).setSession(session);
      if (session.role == UserRole.tutor) {
        if (mounted) context.go('/tutor');
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      setState(() => _error = 'No se pudo registrar');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
