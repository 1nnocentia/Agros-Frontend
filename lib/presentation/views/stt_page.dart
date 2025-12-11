import 'package:flutter/material.dart';

class SttPage extends StatelessWidget {
  const SttPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech-to-Text Page")),
      body: const Center(
        child: Text("STT Functionality Here"),
      ),
    );
  }
}