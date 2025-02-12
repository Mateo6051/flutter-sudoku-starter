import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'game_screen.dart';
import 'end_screen.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Définit l'écran d'accueil comme route initiale
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const Game(title: "Sudoku"),
        '/end': (context) => const EndScreen(),
      },
    );
  }
}
