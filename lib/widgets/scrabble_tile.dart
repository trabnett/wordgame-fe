import 'package:flutter/material.dart';

class ScrabbleTile extends StatelessWidget {
  final String letter;
  final double size;

  const ScrabbleTile({
    super.key,
    required this.letter,
    this.size = 60,
  });

  static const Map<String, int> pointValues = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1, 'F': 4, 'G': 2, 'H': 4,
    'I': 1, 'J': 8, 'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1, 'P': 3,
    'Q': 10, 'R': 1, 'S': 1, 'T': 1, 'U': 1, 'V': 4, 'W': 4, 'X': 8,
    'Y': 4, 'Z': 10,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5DEB3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD4A574), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C1810),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 2,
            child: Text(
              '${pointValues[letter] ?? 0}',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C1810),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
