import 'package:flutter/material.dart';

class ScrabbleTile extends StatelessWidget {
  final String letter;
  final double size;

  const ScrabbleTile({
    super.key,
    required this.letter,
    this.size = 60,
  });

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
      child: Center(
        child: Text(
          letter == 'Q' ? 'Qu' : letter,
          style: TextStyle(
            fontSize: letter == 'Q' ? size * 0.38 : size * 0.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C1810),
          ),
        ),
      ),
    );
  }
}
