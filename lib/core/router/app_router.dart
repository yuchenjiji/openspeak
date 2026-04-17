import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/scenarios/presentation/scenarios_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/scenarios/data/scenario_data.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scenarios',
              builder: (context, state) => const ScenariosPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/chat/:scenarioId',
      builder: (context, state) {
        final scenarioId = state.pathParameters['scenarioId']!;
        final scenario = ScenarioData.all.firstWhere(
          (s) => s.id == scenarioId,
          orElse: () => ScenarioData.all.first,
        );
        return ChatPage(scenario: scenario);
      },
    ),
  ],
);
