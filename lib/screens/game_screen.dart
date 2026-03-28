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
  final TextEditingController _wordController = TextEditingController();
  final FocusNode _wordFocus = FocusNode();

  // Game state
  List<String> _board = [];
  List<String> _hand = [];
  int _yourPileCount = 0;
  int _opponentPileCount = 0;
  bool _yourTurn = false;
  int _opponentHandCount = 0;
  String _status = 'loading';
  String? _lastWord;
  String? _lastPlayer;
  String? _playerOneName;
  String? _playerTwoName;
  String? _error;

  // Game over state
  bool? _winnerIsYou;
  List<String>? _yourPile;
  List<String>? _opponentPile;

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
              _board = List<String>.from(data['board'] ?? []);
              _hand = List<String>.from(data['your_hand'] ?? []);
              _yourPileCount = data['your_pile_count'] ?? 0;
              _opponentPileCount = data['opponent_pile_count'] ?? 0;
              _yourTurn = data['your_turn'] ?? false;
              _opponentHandCount = data['opponent_hand_count'] ?? 0;
              _status = data['status'] ?? 'loading';
              _lastWord = data['last_word'];
              _lastPlayer = data['last_player'];
              _playerOneName = data['player_one_name'];
              _playerTwoName = data['player_two_name'];
              _error = null;
            });
            break;
          case 'error':
            setState(() {
              _error = data['message'];
            });
            break;
          case 'game_over':
            setState(() {
              _status = 'completed';
              _winnerIsYou = data['winner_is_you'];
              _yourPile = List<String>.from(data['your_pile'] ?? []);
              _opponentPile = List<String>.from(data['opponent_pile'] ?? []);
              _yourPileCount = data['your_pile_count'] ?? 0;
              _opponentPileCount = data['opponent_pile_count'] ?? 0;
              _lastWord = data['last_word'];
              _lastPlayer = data['last_player'];
            });
            break;
        }
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  void _submitWord() {
    final word = _wordController.text.trim().toUpperCase();
    if (word.isEmpty) return;

    _channel?.sink.add(jsonEncode({
      'type': 'submit_word',
      'word': word,
    }));

    _wordController.clear();
    setState(() => _error = null);
  }

  void _dumpHand() {
    _channel?.sink.add(jsonEncode({
      'type': 'dump_hand',
    }));
    setState(() => _error = null);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _wordController.dispose();
    _wordFocus.dispose();
    super.dispose();
  }

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
          if (_status == 'loading')
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          if (_status == 'in_progress' || _status == 'completed')
            _buildGameBody(),
          if (_status == 'completed' && _winnerIsYou != null)
            _buildGameOverOverlay(),
        ],
      ),
    );
  }

  Widget _buildGameBody() {
    return Column(
      children: [
        _buildTurnIndicator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Letters in play', _buildBoardTiles()),
                if (_lastWord != null) _buildLastMove(),
                const SizedBox(height: 12),
                _buildScores(),
                const SizedBox(height: 12),
                if (_yourTurn && _status == 'in_progress') _buildWordInput(),
              ],
            ),
          ),
        ),
        _buildHandArea(),
      ],
    );
  }

  Widget _buildTurnIndicator() {
    final text = _yourTurn ? 'Your turn!' : 'Waiting for opponent...';
    final color = _yourTurn ? Colors.greenAccent : Colors.white54;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: _yourTurn
          ? Colors.greenAccent.withValues(alpha: 0.1)
          : Colors.transparent,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildBoardTiles() {
    if (_board.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          'No letters in play yet',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: _board
          .map((letter) => ScrabbleTile(letter: letter, size: 44))
          .toList(),
    );
  }

  Widget _buildLastMove() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.history, size: 16, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(
            '$_lastPlayer played ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          Text(
            _lastWord!,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScores() {
    return Row(
      children: [
        _buildScoreChip('You', _yourPileCount, _hand.length),
        const SizedBox(width: 12),
        _buildScoreChip('Opponent', _opponentPileCount, _opponentHandCount),
      ],
    );
  }

  Widget _buildScoreChip(String label, int pileCount, int handCount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$pileCount cards taken',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$handCount cards in hand',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _wordController,
                focusNode: _wordFocus,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a word...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF16213E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _submitWord(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submitWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Play', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _dumpHand,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Dump Hand'),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildHandArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your hand (${_hand.length})',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: _hand
                .map((letter) => ScrabbleTile(letter: letter, size: 44))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final isWinner = _winnerIsYou == true;
    final isTie = _winnerIsYou == null;

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isTie)
                Text(
                  isWinner ? '\u{1F3C6}' : '',
                  style: const TextStyle(fontSize: 64),
                ),
              const SizedBox(height: 16),
              Text(
                isTie ? "It's a tie!" : (isWinner ? 'You win!' : 'You lost!'),
                style: TextStyle(
                  color: isTie
                      ? Colors.white
                      : (isWinner ? Colors.amber : Colors.white),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_lastWord != null)
                Text(
                  'Final word: $_lastWord by $_lastPlayer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPileSummary('You', _yourPileCount, _yourPile),
                  const SizedBox(width: 24),
                  _buildPileSummary('Opponent', _opponentPileCount, _opponentPile),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/lobby'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16213E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text('Back to Lobby'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPileSummary(String label, int count, List<String>? pile) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count cards',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (pile != null && pile.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              pile.join(', '),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}
