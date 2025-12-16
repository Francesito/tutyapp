import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/api_client.dart';
import '../domain/student_repository.dart';
import '../../auth/providers/session_provider.dart';

class JustificationScreen extends ConsumerStatefulWidget {
  const JustificationScreen({super.key});

  @override
  ConsumerState<JustificationScreen> createState() => _JustificationScreenState();
}

class _JustificationScreenState extends ConsumerState<JustificationScreen> {
  final _reason = TextEditingController();
  String _status = '';
  File? _pickedFile;
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar justificante')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _reason,
                    decoration: const InputDecoration(labelText: 'Motivo', filled: true),
                  ),
                  const SizedBox(height: 12),
                  const Text('Evidencia (JPG, máx 2MB):'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _pickedFile?.path.split('/').last ?? 'Sin archivo',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Adjuntar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _uploading ? null : _submit,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar (máx 2 por cuatrimestre)'),
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
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_pickedFile == null) {
      setState(() => _status = 'Adjunta una imagen JPG (<2MB)');
      return;
    }
    try {
      setState(() {
        _uploading = true;
        _status = 'Subiendo evidencia...';
      });
      final token = ref.read(sessionProvider).session?.token;
      final repo = StudentRepository(ApiClient(token: token));
      final url = await repo.uploadEvidence(_pickedFile!);
      await repo.submitJustification(_reason.text, url);
      setState(() => _status = 'Enviado');
    } catch (e) {
      setState(() => _status = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.size > 2 * 1024 * 1024) {
      setState(() => _status = 'El archivo excede 2MB');
      return;
    }
    final path = file.path;
    if (path == null) {
      setState(() => _status = 'No se pudo leer el archivo');
      return;
    }
    setState(() {
      _pickedFile = File(path);
      _status = '';
    });
  }
}
