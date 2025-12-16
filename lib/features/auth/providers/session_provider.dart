import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models.dart';

class SessionController extends ChangeNotifier {
  UserSession? _session;

  UserSession? get session => _session;

  bool get isAuthenticated => _session != null;

  UserRole get role => _session?.role ?? UserRole.student;

  void setSession(UserSession? newSession) {
    _session = newSession;
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }
}

final sessionProvider = ChangeNotifierProvider<SessionController>((ref) {
  return SessionController();
});
