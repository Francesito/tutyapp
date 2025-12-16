import '../../../core/models.dart';
import '../../../data/api_client.dart';

class AuthRepository {
  Future<UserSession> login(String email, String password) async {
    final api = ApiClient();
    final res = await api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    final token = res['token'] as String;
    return UserSession.fromJson(res['user'] as Map<String, dynamic>, token);
  }

  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final api = ApiClient();
    final res = await api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
    });
    final token = res['token'] as String;
    return UserSession.fromJson(res['user'] as Map<String, dynamic>, token);
  }
}
