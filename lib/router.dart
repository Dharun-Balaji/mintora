import 'package:go_router/go_router.dart';
import 'ui/login_screen.dart';
import 'ui/main_screen.dart';
import 'ui/home_screen.dart';
import 'ui/transactions_screen.dart';
import 'ui/goals_screen.dart';
import 'ui/ai_chat_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/ai_report_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: '/goals',
          builder: (context, state) => const GoalsScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const AIChatScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/ai-report',
      builder: (context, state) => const AIReportScreen(),
    ),
  ],
);
