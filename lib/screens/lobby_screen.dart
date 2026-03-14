import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _inviteController = TextEditingController();
  String? _message;
  bool _isError = false;
  bool _loading = false;

  Future<void> _createGame({String? phoneNumber}) async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final token = AuthService().accessToken!;
      final result = await _apiService.createGame(token, phoneNumber: phoneNumber);
      if (!mounted) return;

      if (result['success'] == true) {
        final game = result['game'];
        final gameId = game['id'];
        final gameStatus = game['status'];

        if (gameStatus == 'waiting') {
          context.go('/waiting/$gameId');
        } else {
          context.go('/game/$gameId');
        }
      } else {
        setState(() {
          _message = result['message'] ?? 'Failed to create game.';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Could not reach the server.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sendInvite() {
    final phone = _inviteController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _message = 'Please enter a phone number.';
        _isError = true;
      });
      return;
    }
    _createGame(phoneNumber: phone);
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = AuthService().firstName ?? 'Player';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('WordGame'),
        backgroundColor: const Color(0xFF16213E),
        actions: [
          TextButton(
            onPressed: () => context.go('/user'),
            child: Text(
              'Hi, $firstName',
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome, $firstName!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Create game button
                ElevatedButton.icon(
                  onPressed: _loading ? null : () => _createGame(),
                  icon: const Icon(Icons.play_arrow),
                  label: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Game'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or invite a friend',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                  ],
                ),
                const SizedBox(height: 24),

                // Invite by phone
                TextField(
                  controller: _inviteController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    prefixIcon: const Icon(Icons.person_add, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF16213E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendInvite(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _sendInvite,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Invite'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                    foregroundColor: Colors.white,
                  ),
                ),

                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _isError ? Colors.redAccent : Colors.greenAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
