import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/lobby_screen.dart';
import '../screens/waiting_screen.dart';
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
      return '/lobby';
    }

    if (!loggedIn && (path.startsWith('/lobby') || path.startsWith('/game') || path.startsWith('/waiting') || path == '/user')) {
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
      path: '/lobby',
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/waiting/:gameId',
      builder: (context, state) => WaitingScreen(
        gameId: int.parse(state.pathParameters['gameId']!),
      ),
    ),
    GoRoute(
      path: '/game/:gameId',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserScreen(),
    ),
  ],
);
