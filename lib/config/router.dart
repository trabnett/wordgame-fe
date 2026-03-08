import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/not_found_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
  ],
);
