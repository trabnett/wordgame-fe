import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ApiService _apiService = ApiService();
  String _message = 'Connecting...';
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _fetchWelcome();
  }

  Future<void> _fetchWelcome() async {
    try {
      final data = await _apiService.getWelcome();
      setState(() {
        _message = data['message'] ?? 'No message';
        _connected = data['success'] ?? false;
      });
    } catch (e) {
      setState(() {
        _message = 'Could not reach backend';
        _connected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Maranga',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),
            Icon(
              _connected ? Icons.check_circle : Icons.sync,
              color: _connected ? Colors.greenAccent : Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _connected ? Colors.greenAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
