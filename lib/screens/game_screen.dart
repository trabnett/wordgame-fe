import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/constants.dart';
import '../services/auth_service.dart';
import '../widgets/scrabble_tile.dart';

class GameScreen extends StatefulWidget {
  final int gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  WebSocketChannel? _channel;
  List<String?> _boardSlots = List.filled(5, null);
  List<String> _handLetters = [];
  String _status = 'loading';
  bool? _winnerIsYou;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final token = AuthService().accessToken;
    final uri = Uri.parse('$wsBaseUrl/game/${widget.gameId}/?token=$token');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (!mounted) return;

        switch (data['type']) {
          case 'game_state':
            setState(() {
              _boardSlots = List<String?>.from(data['board_state']);
              _handLetters = List<String>.from(data['hand_letters']);
              _status = data['status'];
            });
            break;
          case 'game_update':
            setState(() {
              _boardSlots = List<String?>.from(data['board_state']);
              _handLetters = List<String>.from(data['hand_letters']);
            });
            break;
          case 'game_over':
            setState(() {
              _status = 'completed';
              _winnerIsYou = data['winner_is_you'];
              _boardSlots = List<String?>.from(data['board_state']);
            });
            break;
        }
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  void _placeTile(int slotIndex, int handIndex) {
    // Optimistic local update
    setState(() {
      _boardSlots[slotIndex] = _handLetters[handIndex];
      _handLetters[handIndex] = '';
    });

    _channel?.sink.add(jsonEncode({
      'type': 'place_tile',
      'slot_index': slotIndex,
      'hand_index': handIndex,
    }));
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  bool get _isPlayable => _status == 'in_progress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('WordGame'),
        backgroundColor: const Color(0xFF16213E),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => context.go('/user'),
                child: Text(
                  'Hi, ${AuthService().firstName ?? 'Player'}',
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Board area
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return DragTarget<Map<String, dynamic>>(
                        onWillAcceptWithDetails: (_) =>
                            _isPlayable && _boardSlots[index] == null,
                        onAcceptWithDetails: (details) {
                          final data = details.data;
                          final handIndex = data['hand_index'] as int;
                          _placeTile(index, handIndex);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final letter = _boardSlots[index];
                          final isHovering = candidateData.isNotEmpty;

                          if (letter != null) {
                            return Padding(
                              padding: const EdgeInsets.all(4),
                              child: ScrabbleTile(letter: letter),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: _emptySlot(isHovering: isHovering),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),

              // Hand area
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF16213E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_handLetters.length, (index) {
                    final letter = _handLetters[index];

                    if (letter.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: _emptySlot(isHovering: false),
                      );
                    }

                    if (!_isPlayable) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: ScrabbleTile(letter: letter),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Draggable<Map<String, dynamic>>(
                        data: {
                          'letter': letter,
                          'hand_index': index,
                        },
                        feedback: Material(
                          color: Colors.transparent,
                          child: ScrabbleTile(letter: letter),
                        ),
                        childWhenDragging: _emptySlot(isHovering: false),
                        child: ScrabbleTile(letter: letter),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // Game over overlay
          if (_status == 'completed' && _winnerIsYou != null)
            _buildGameOverOverlay(),

          // Loading state
          if (_status == 'loading')
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final isWinner = _winnerIsYou!;
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWinner ? '\u{1F3C6}' : '',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              isWinner ? 'You win!' : 'You lost!',
              style: TextStyle(
                color: isWinner ? Colors.amber : Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/lobby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16213E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Back to Lobby'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySlot({required bool isHovering}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isHovering
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHovering
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
    );
  }
}
