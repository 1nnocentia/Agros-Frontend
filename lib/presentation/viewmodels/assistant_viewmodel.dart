import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
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
  static final Logger _logger = Logger('AssistantViewModel');
  
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

    ttsVm.addListener(() {
      if (ttsVm.ttsState == TtsState.stopped && _state == AgrosState.speaking) {
        startStandbyMode();
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
    _logger.info('AGROS: Mode Standby (Menunggu dipanggil)...');
  }

  Future<void> _startListeningUser() async {
    _setState(AgrosState.listeningCommand);

    await wakeWordVm.stopListening();
    
    _logger.info('AGROS: Mendengarkan perintah user...');
    
    sttVm.startListening();
  }

  Future<void> _processToAI(String text) async {
    _setState(AgrosState.processing);
    _logger.info('AGROS: Mengirim ke AI -> $text');

    await Future.delayed(const Duration(seconds: 10));

    _speakResponse("Saya mendengar anda berkata: $text");
  }

  Future<void> _speakResponse(String responseText) async {
    _setState(AgrosState.speaking);
    _lastResponse = responseText;
    notifyListeners();
    await ttsVm.speak(responseText);
    
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