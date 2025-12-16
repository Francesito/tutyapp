import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';
import '../../../core/models.dart';
import '../../../data/api_client.dart';

class StudentRepository {
  StudentRepository(this._api);
  final ApiClient _api;

  Future<void> joinGroup(String code) async {
    await _api.post('/groups/join', {'code': code});
  }

  Future<void> submitMood(String emoji, String? note) async {
    await _api.post('/students/mood', {'emoji': emoji, 'note': note});
  }

  Future<void> submitPerception(String subject, String perception) async {
    await _api.post('/students/perceptions', {
      'subject': subject,
      'perception': perception,
    });
  }

  Future<void> submitJustification(String reason, String evidenceUrl) async {
    await _api.post('/students/justifications', {
      'reason': reason,
      'evidenceUrl': evidenceUrl,
    });
  }

  Future<List<MoodEntry>> fetchMoodHistory() async {
    final res = await _api.get('/students/mood');
    final data = (res['items'] as List<dynamic>)
        .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return data;
  }

  Future<List<PerceptionEntry>> fetchPerceptions() async {
    final res = await _api.get('/students/perceptions');
    return (res['items'] as List<dynamic>)
        .map((e) => PerceptionEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<JustificationRequest>> fetchJustifications() async {
    final res = await _api.get('/students/justifications');
    return (res['items'] as List<dynamic>)
        .map((e) => JustificationRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> uploadEvidence(File file) async {
    final uri = Uri.parse('$apiBaseUrl/uploads/justification-image');
    final request = http.MultipartRequest('POST', uri);
    if (_api.token != null) {
      request.headers['Authorization'] = 'Bearer ${_api.token}';
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 400) {
      throw Exception('Error subiendo evidencia: ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['url'] as String;
  }
}
