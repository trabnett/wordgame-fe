import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/constants.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class WaitingScreen extends StatefulWidget {
  final int gameId;

  const WaitingScreen({super.key, required this.gameId});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final ApiService _apiService = ApiService();
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _tryJoinGame();
  }

  Future<void> _tryJoinGame() async {
    try {
      final token = AuthService().accessToken!;
      final result = await _apiService.joinGame(token, widget.gameId);
      if (!mounted) return;

      if (result['success'] == true) {
        context.go('/game/${widget.gameId}');
      }
      // If join fails (e.g. we're the creator), just keep waiting
    } catch (_) {}
  }

  void _connectWebSocket() {
    final token = AuthService().accessToken;
    final uri = Uri.parse('$wsBaseUrl/game/${widget.gameId}/?token=$token');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data['type'] == 'game_start' && mounted) {
          context.go('/game/${widget.gameId}');
        }
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('WordGame'),
        backgroundColor: const Color(0xFF16213E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/lobby'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 32),
              Text(
                'Waiting for an opponent...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Game #${widget.gameId}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: () => context.go('/lobby'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Back to Lobby'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
