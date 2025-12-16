import '../../../core/models.dart';
import '../../../data/api_client.dart';

class TutorRepository {
  TutorRepository(this._api);
  final ApiClient _api;

  Future<void> createGroup(String code, String term) async {
    await _api.post('/groups', {'code': code, 'term': term});
  }

  Future<List<AlertItem>> fetchAlerts() async {
    final res = await _api.get('/tutor/alerts');
    return (res['items'] as List<dynamic>)
        .map((e) => AlertItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateJustification(int id, String status) async {
    await _api.post('/tutor/justifications', {'id': id, 'status': status});
  }

  Future<Map<String, dynamic>> fetchPanel() async {
    return _api.get('/tutor/panel');
  }
}
