import 'package:go_router/go_router.dart';

import '../features/parent/change_pin_screen.dart';
import '../features/parent/parent_screen.dart';
import '../features/parent/profile_form_screen.dart';
import '../features/profiles/kid_home_screen.dart';
import '../features/profiles/profile_picker_screen.dart';
import '../features/session/session_screen.dart';

GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: '/kid/:id',
      builder: (_, s) =>
          KidHomeScreen(profileId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/kid/:id/session',
      builder: (_, s) =>
          SessionScreen(profileId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(path: '/parent', builder: (_, _) => const ParentScreen()),
    GoRoute(
      path: '/parent/profiles/new',
      builder: (_, _) => const ProfileFormScreen(),
    ),
    GoRoute(
      path: '/parent/profiles/:id',
      builder: (_, s) =>
          ProfileFormScreen(profileId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(path: '/parent/pin', builder: (_, _) => const ChangePinScreen()),
  ],
);
