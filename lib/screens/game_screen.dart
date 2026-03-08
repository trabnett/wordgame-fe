import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/scrabble_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();
  late List<String> _handLetters;
  late List<String?> _boardSlots;

  @override
  void initState() {
    super.initState();
    _handLetters = List.generate(3, (_) => _randomLetter());
    _boardSlots = List.filled(5, null);
  }

  String _randomLetter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return letters[_random.nextInt(letters.length)];
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
      body: Column(
        children: [
          // Board area
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return DragTarget<Map<String, dynamic>>(
                    onWillAcceptWithDetails: (_) => _boardSlots[index] == null,
                    onAcceptWithDetails: (details) {
                      setState(() {
                        final data = details.data;
                        final source = data['source'] as String;
                        final sourceIndex = data['index'] as int;
                        final letter = data['letter'] as String;

                        if (source == 'hand') {
                          _handLetters[sourceIndex] = '';
                        } else if (source == 'board') {
                          _boardSlots[sourceIndex] = null;
                        }

                        _boardSlots[index] = letter;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      final letter = _boardSlots[index];
                      final isHovering = candidateData.isNotEmpty;

                      if (letter != null) {
                        return Padding(
                          padding: const EdgeInsets.all(4),
                          child: Draggable<Map<String, dynamic>>(
                            data: {
                              'letter': letter,
                              'index': index,
                              'source': 'board',
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: ScrabbleTile(letter: letter),
                            ),
                            childWhenDragging: _emptySlot(isHovering: false),
                            onDragCompleted: () {
                              // Only clear if moved to a new valid target
                            },
                            child: ScrabbleTile(letter: letter),
                          ),
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
                    child: DragTarget<Map<String, dynamic>>(
                      onWillAcceptWithDetails: (_) => true,
                      onAcceptWithDetails: (details) {
                        setState(() {
                          final data = details.data;
                          final source = data['source'] as String;
                          final sourceIndex = data['index'] as int;
                          final draggedLetter = data['letter'] as String;

                          if (source == 'board') {
                            _boardSlots[sourceIndex] = null;
                          } else if (source == 'hand') {
                            _handLetters[sourceIndex] = '';
                          }

                          _handLetters[index] = draggedLetter;
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return _emptySlot(
                          isHovering: candidateData.isNotEmpty,
                        );
                      },
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Draggable<Map<String, dynamic>>(
                    data: {
                      'letter': letter,
                      'index': index,
                      'source': 'hand',
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
