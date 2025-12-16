class UserSession {
  final int id;
  final String email;
  final UserRole role;
  final String token;
  final String? name;

  UserSession({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    this.name,
  });

  factory UserSession.fromJson(Map<String, dynamic> json, String token) {
    return UserSession(
      id: json['id'] as int,
      email: json['email'] as String,
      role: (json['role'] as String).toLowerCase() == 'tutor'
          ? UserRole.tutor
          : UserRole.student,
      token: token,
      name: json['name'] as String?,
    );
  }
}

enum UserRole { student, tutor }

class MoodEntry {
  final String emoji;
  final String? note;
  final DateTime date;

  MoodEntry({required this.emoji, this.note, required this.date});

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        emoji: json['emoji'] as String,
        note: json['note'] as String?,
        date: DateTime.parse(json['date'] as String),
      );
}

class PerceptionEntry {
  final String subject;
  final String perception;
  final DateTime weekOf;

  PerceptionEntry(
      {required this.subject, required this.perception, required this.weekOf});

  factory PerceptionEntry.fromJson(Map<String, dynamic> json) => PerceptionEntry(
        subject: json['subject'] as String,
        perception: json['perception'] as String,
        weekOf: DateTime.parse(json['weekOf'] as String),
      );
}

class JustificationRequest {
  final int id;
  final String reason;
  final String evidenceUrl;
  final String status;

  JustificationRequest({
    required this.id,
    required this.reason,
    required this.evidenceUrl,
    required this.status,
  });

  factory JustificationRequest.fromJson(Map<String, dynamic> json) =>
      JustificationRequest(
        id: json['id'] as int,
        reason: json['reason'] as String,
        evidenceUrl: json['evidenceUrl'] as String,
        status: json['status'] as String,
      );
}

class AlertItem {
  final String type;
  final String message;

  AlertItem({required this.type, required this.message});

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      AlertItem(type: json['type'] as String, message: json['message'] as String);
}

class GroupSummary {
  final String code;
  final int studentCount;
  final List<AlertItem> alerts;

  GroupSummary({
    required this.code,
    required this.studentCount,
    required this.alerts,
  });
}
