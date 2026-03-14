import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/constants.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class FindGameScreen extends StatefulWidget {
  const FindGameScreen({super.key});

  @override
  State<FindGameScreen> createState() => _FindGameScreenState();
}

class _FindGameScreenState extends State<FindGameScreen> {
  final ApiService _apiService = ApiService();
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _waitingGames = [];
  bool _joining = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse('$wsBaseUrl/lobby/'));
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message as String);
        if (data['type'] == 'waiting_games') {
          if (mounted) {
            setState(() {
              _waitingGames = List<Map<String, dynamic>>.from(data['games']);
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _errorMessage = 'Lost connection to server.');
        }
      },
      onDone: () {
        if (mounted) {
          setState(() => _errorMessage = 'Connection closed.');
        }
      },
    );
  }

  Future<void> _joinGame(int gameId) async {
    setState(() {
      _joining = true;
      _errorMessage = null;
    });

    try {
      final token = AuthService().accessToken!;
      final result = await _apiService.joinGame(token, gameId);
      if (!mounted) return;

      if (result['success'] == true) {
        final game = result['game'];
        context.go('/game/${game['id']}');
      } else {
        setState(() => _errorMessage = result['message'] ?? 'Failed to join game.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not reach the server.');
    } finally {
      if (mounted) setState(() => _joining = false);
    }
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
        title: const Text('Find a Game'),
        backgroundColor: const Color(0xFF16213E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/lobby'),
        ),
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.redAccent.withValues(alpha: 0.2),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _waitingGames.isEmpty
                ? Center(
                    child: Text(
                      'No games waiting for players.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _waitingGames.length,
                    itemBuilder: (context, index) {
                      final game = _waitingGames[index];
                      return Card(
                        color: const Color(0xFF16213E),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1A1A2E),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            game['player_one'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Game #${game['id']}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: _joining ? null : () => _joinGame(game['id']),
                            child: const Text('Join'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
