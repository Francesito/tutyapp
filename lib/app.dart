import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants.dart';
import 'core/models.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/providers/session_provider.dart';
import 'features/student/presentation/chat_screen.dart';
import 'features/student/presentation/history_screen.dart';
import 'features/student/presentation/justification_screen.dart';
import 'features/student/presentation/mood_entry_screen.dart';
import 'features/student/presentation/perception_screen.dart';
import 'features/student/presentation/student_home_screen.dart';
import 'features/tutor/presentation/create_group_screen.dart';
import 'features/tutor/presentation/tutor_home_screen.dart';
import 'features/tutor/presentation/tutor_justifications_screen.dart';
import 'features/tutor/presentation/tutor_panel_screen.dart';
import 'features/tutor/presentation/tutor_reports_screen.dart';
import 'features/tutor/presentation/tutor_student_detail_screen.dart';

class TutorTrackApp extends ConsumerWidget {
  const TutorTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _buildRouter(ref);
    return MaterialApp.router(
      title: 'TutorTrack',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        brightness: Brightness.light,
      ),
      routerConfig: router,
    );
  }

  GoRouter _buildRouter(WidgetRef ref) {
    final session = ref.read(sessionProvider);

    return GoRouter(
      initialLocation: session.isAuthenticated ? '/home' : '/login',
      refreshListenable: session,
      redirect: (context, state) {
        final loggedIn = session.isAuthenticated;
        final loggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) {
          return session.role == UserRole.tutor ? '/tutor' : '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const StudentHomeScreen(),
          routes: [
            GoRoute(
              path: 'mood',
              builder: (context, state) => const MoodEntryScreen(),
            ),
            GoRoute(
              path: 'perception',
              builder: (context, state) => const PerceptionScreen(),
            ),
            GoRoute(
              path: 'justifications',
              builder: (context, state) => const JustificationScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: 'chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/tutor',
          builder: (context, state) => const TutorHomeScreen(),
          routes: [
            GoRoute(
              path: 'panel',
              builder: (context, state) => const TutorPanelScreen(),
            ),
            GoRoute(
              path: 'groups/create',
              builder: (context, state) => const CreateGroupScreen(),
            ),
            GoRoute(
              path: 'students/:id',
              builder: (context, state) =>
                  TutorStudentDetailScreen(studentId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'justifications',
              builder: (context, state) => const TutorJustificationsScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const TutorReportsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
