import 'package:flutter/material.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Victory")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You solved it!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text("Go to main menu"),
            ),
          ],
        ),
      ),
    );
  }
}
