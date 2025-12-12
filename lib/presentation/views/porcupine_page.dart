import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agros/presentation/viewmodels/porcupine_viewmodel.dart';

class PorcupinePage extends StatelessWidget {
  const PorcupinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PorcupineViewModel()..initService(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Tes Wake Word")),
        
        body: Consumer<PorcupineViewModel>(
          builder: (context, vm, child) {
            
            return Container(
              color: vm.isWakeWordDetected ? Colors.greenAccent : Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      vm.isWakeWordDetected ? Icons.mic : Icons.mic_none,
                      size: 100,
                      color: vm.isListening ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        vm.status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    ElevatedButton(
                      onPressed: () => vm.toggleListening(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                      child: Text(
                        vm.isListening ? "STOP LISTENING" : "START LISTENING",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}