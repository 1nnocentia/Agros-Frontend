import 'package:flutter/material.dart';
import 'porcupine_viewmodel.dart';
import 'stt_viewmodel.dart';
import 'tts_viewmodel.dart';

enum AgrosState {
  standby,
  listeningCommand,
  processing,
  speaking
}

class AssistantViewModel extends ChangeNotifier {
  final PorcupineViewModel wakeWordVm;
  final SttViewmodel sttVm;
  final TtsViewModel ttsVm; 

  AgrosState _state = AgrosState.standby;
  AgrosState get state => _state;

  String _lastResponse = "";
  String get lastResponse => _lastResponse;

  AssistantViewModel({
    required this.wakeWordVm,
    required this.sttVm,
    required this.ttsVm,
  }) {
    _initFlow();
  }

  void _initFlow() {
    wakeWordVm.addListener(() {
      if (wakeWordVm.isWakeWordDetected) {
        _startListeningUser();
      }
    });

    sttVm.addListener(() {
      if (!sttVm.isListening && sttVm.lastWords.isNotEmpty && _state == AgrosState.listeningCommand) {
        _processToAI(sttVm.lastWords);
      }
    });

    startStandbyMode();
  }

  Future<void> startStandbyMode() async {
    _setState(AgrosState.standby);
    _lastResponse = "";
    
    wakeWordVm.resetDetection();
    
    sttVm.stopListening();
    await ttsVm.stop();

    await wakeWordVm.startListening();
    print("AGROS: Mode Standby (Menunggu dipanggil)...");
  }

  Future<void> _startListeningUser() async {
    _setState(AgrosState.listeningCommand);

    await wakeWordVm.stopListening();
    
    print("AGROS: Mendengarkan perintah user...");
    
    sttVm.startListening();
  }

  Future<void> _processToAI(String text) async {
    _setState(AgrosState.processing);
    print("AGROS: Mengirim ke AI -> $text");

    await Future.delayed(const Duration(seconds: 10));

    _speakResponse("Saya mendengar anda berkata: $text");
  }

  Future<void> _speakResponse(String responseText) async {
    _setState(AgrosState.speaking);
    _lastResponse = responseText;
    notifyListeners();
    await ttsVm.speak(responseText);

    // TODO: Nanti kita tambahkan logika untuk mendeteksi kapan TTS selesai
    // Untuk sekarang, user harus tekan tombol manual untuk kembali standby
    // atau kita set timer estimasi.
    
    // Untuk testing, kita balik ke standby setelah 5 detik
    Future.delayed(const Duration(seconds: 5), () {
        startStandbyMode();
    });
  }

  void _setState(AgrosState s) {
    _state = s;
    notifyListeners();
  }

  void manualStartListening() {
    _startListeningUser();
  }

  void manualStopListening() {
    sttVm.stopListening();
  }
}