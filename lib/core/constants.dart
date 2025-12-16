import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E88E5);
  static const danger = Color(0xFFD32F2F);
  static const success = Color(0xFF2E7D32);
  static const background = Color(0xFFF6F7FB);
}

class AppText {
  static const appName = 'TutorTrack';
}

class MoodOptions {
  static const emojis = ['😀', '🙂', '😐', '🙁', '😢'];
}

class PerceptionOptions {
  static const options = [
    '👍 Excelente',
    '🙂 Bien',
    '😐 Neutral',
    '🙁 Difícil',
    '😱 Crítico',
  ];
}

class AppConstraints {
  static const justificationLimit = 2;
}

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:4000',
);
