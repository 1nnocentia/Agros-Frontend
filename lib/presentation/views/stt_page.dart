import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agros/presentation/viewmodels/stt_viewmodel.dart';

// --- MAIN PAGE ---
class SpeechSamplePage extends StatelessWidget {
  const SpeechSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject ViewModel
    return ChangeNotifierProvider(
      create: (_) => SttViewmodel()..initSpeechState(), // Auto init saat dibuka
      child: Scaffold(
        appBar: AppBar(title: const Text('MVVM Speech to Text')),
        body: Consumer<SttViewmodel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Header Control (Init & Settings)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: vm.hasSpeech ? null : vm.initSpeechState,
                            child: const Text('Initialize'),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            // Buka Dialog Settings (Logic UI dipisah di bawah)
                            await _showSetUp(context, vm);
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Options'),
                        ),
                      ],
                    ),
                  ),

                  SpeechControlWidget(
                    hasSpeech: vm.hasSpeech,
                    isListening: vm.isListening,
                    startListening: vm.startListening,
                    stopListening: vm.stopListening,
                    cancelListening: vm.cancelListening,
                  ),

                  RecognitionResultsWidget(
                    lastWords: vm.lastWords,
                    level: vm.soundLevelNotifier.value,
                  ),

                  SpeechStatusWidget(lastStatus: vm.lastStatus),

                  ErrorDisplayWidget(lastError: vm.lastError),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class SpeechControlWidget extends StatelessWidget {
  final bool hasSpeech;
  final bool isListening;
  final VoidCallback startListening;
  final VoidCallback stopListening;
  final VoidCallback cancelListening;

  const SpeechControlWidget({
    super.key,
    required this.hasSpeech,
    required this.isListening,
    required this.startListening,
    required this.stopListening,
    required this.cancelListening,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
          onPressed: !hasSpeech || isListening ? null : startListening,
          child: const Text('Start'),
        ),
        TextButton(
          onPressed: isListening ? stopListening : null,
          child: const Text('Stop'),
        ),
        TextButton(
          onPressed: isListening ? cancelListening : null,
          child: const Text('Cancel'),
        )
      ],
    );
  }
}

class RecognitionResultsWidget extends StatelessWidget {
  final String lastWords;
  final double level;

  const RecognitionResultsWidget({
    super.key,
    required this.lastWords,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Center(child: Text('Recognized Words', style: TextStyle(fontSize: 20))),
        Stack(
          children: <Widget>[
            Container(
              constraints: const BoxConstraints(minHeight: 200),
              color: Colors.grey[200],
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Center(child: Text(lastWords, textAlign: TextAlign.center)),
            ),
            Positioned.fill(
              bottom: 10,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: MicrophoneWidget(level: level),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MicrophoneWidget extends StatelessWidget {
  final double level;
  const MicrophoneWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: .26,
            spreadRadius: level * 1.5,
            color: Colors.black.withOpacity(.05),
          )
        ],
      ),
      child: const Icon(Icons.mic),
    );
  }
}

class SpeechStatusWidget extends StatelessWidget {
  final String lastStatus;
  const SpeechStatusWidget({super.key, required this.lastStatus});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Status', style: TextStyle(fontSize: 18)),
        ),
        Center(child: Text(lastStatus)),
      ],
    );
  }
}

class ErrorDisplayWidget extends StatelessWidget {
  final String lastError;
  const ErrorDisplayWidget({super.key, required this.lastError});

  @override
  Widget build(BuildContext context) {
    if (lastError.isEmpty) return const SizedBox.shrink();
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Error', style: TextStyle(color: Colors.red, fontSize: 18)),
        ),
        Center(child: Text(lastError, style: const TextStyle(color: Colors.red))),
      ],
    );
  }
}


Future<void> _showSetUp(BuildContext context, SttViewmodel vm) async {
  // Logic Dialog ini agak panjang, idealnya dipisah ke Widget sendiri 
  // Tapi untuk mempersingkat, intinya dia memanggil vm.updateConfig()
  
  // Implementasi UI SessionOptionsWidget bisa ditaruh di sini
  // dan memanggil vm.updateConfig(newConfig) saat user mengubah nilai.
  // (Menggunakan kode SessionOptionsWidget asli Anda, tapi passing callback ke VM)
}