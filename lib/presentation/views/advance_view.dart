import 'package:flutter/material.dart';

class AdvanceView extends StatefulWidget {
  const AdvanceView({super.key});

  @override
  State<AdvanceView> createState() => _AdvanceViewState();
}

class _AdvanceViewState extends State<AdvanceView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Advance View - Sedang dalam pengembangan"),
      ),
    );
  }
}