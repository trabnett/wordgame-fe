import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'config/router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const WordGameApp());
}

class WordGameApp extends StatelessWidget {
  const WordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WordGame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: router,
    );
  }
}
