import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/game_screen.dart';
import '../screens/user_screen.dart';
import '../screens/not_found_screen.dart';
import '../services/auth_service.dart';

final router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  redirect: (context, state) {
    final loggedIn = AuthService().isLoggedIn;
    final path = state.uri.path;

    if (loggedIn && (path == '/' || path == '/login')) {
      return '/game';
    }

    if (!loggedIn && (path == '/game' || path == '/user')) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserScreen(),
    ),
  ],
);
