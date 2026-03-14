import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WaitingScreen extends StatelessWidget {
  final int gameId;

  const WaitingScreen({super.key, required this.gameId});

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
                'Game #$gameId',
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
