import 'dart:convert';
import 'package:agros/core/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:agros/core/services/api_service.dart';
import 'package:agros/data/repositories/agros_repository.dart';

import 'package:agros/data/models/chat_message.dart';

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

  final AiService _aiService = AiService();
  final AgrosRepository _repo = AgrosRepository();

  AgrosState _state = AgrosState.standby;
  AgrosState get state => _state;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

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
        Future.delayed(const Duration(milliseconds: 500), () {
          startStandbyMode();
        });
      }
    });

    startStandbyMode();
  }

  Future<void> startStandbyMode() async {
    _setState(AgrosState.standby);
    
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
    _addMessage(text, true)

    try {
      final rawResponse = await _aiService.sendMessage(userText);
      
      final (speechText, jsonData) = _parseAiResponse(rawResponse);
      
      String finalFeedback = speechText;

      if (jsonData != null && jsonData.containsKey('intent')) {
        final intent = jsonData['intent'];
        final data = jsonData['data'] ?? {};

        _logger.info("🤖 INTENT DETECTED: $intent | DATA: $data");

        bool success = await _executeIntent(intent, data);
        
        if (!success) {
          finalFeedback = "Maaf, data gagal disimpan ke sistem. Tolong cek koneksi internet.";
        }
      }

      _addMessage(finalFeedback, false);
      await _speakResponse(finalFeedback);

    } catch (e) {
      _logger.severe("Error Processing: $e");
      _addMessage("Error: $e", false, isError: true);
      await _speakResponse("Maaf Sahabat Agros, ada gangguan sistem.");
    }
  }

  Future<bool> _executeIntent(String intent, Map<String, dynamic> data) async {
    String? extractId() {
       if (data.containsKey('id')) return data['id'].toString();
       for (var key in data.keys) {
         if (key.endsWith('_id') && key != 'role_id') return data[key].toString();
       }
       return null;
    }

    try {
      switch (intent) {
        case 'create_lahan':
          return await _repo.lahan.createLahan(data);
        
        case 'update_lahan':
          final id = extractId();
          if (id == null) return false;
          data.remove('id'); data.remove('lahan_id');
          return await _repo.lahan.updateLahan(id, data);

        case 'create_tanam':
          return await _repo.tanam.createTanam(data);
        
        case 'update_tanam':
          final id = extractId();
          if (id == null) return false;
          data.remove('id'); data.remove('tanam_id');
          return await _repo.tanam.updateTanam(id, data);

        case 'create_panen':
          return await _repo.panen.createPanen(data);

        case 'update_panen':
          final id = extractId();
          if (id == null) return false;
          data.remove('id'); data.remove('panen_id');
          return await _repo.panen.updatePanen(id, data);

        case 'update_user':
        case 'update_profile':
          return await _repo.auth.updateProfile(data);

        default:
          _logger.warning("Intent tidak dikenali: $intent");
          return true;
      }
    } catch (e) {
      _logger.severe("Gagal eksekusi intent $intent: $e");
      return false;
    }
  }

  Future<void> _speakResponse(String responseText) async {
    _setState(AgrosState.speaking);
    await ttsVm.speak(responseText);
    
  }

  (String, Map<String, dynamic>?) _parseAiResponse(String raw) {
    try {
      int start = raw.indexOf('{');
      int end = raw.lastIndexOf('}');
      
      if (start != -1 && end != -1 && end > start) {
        String jsonPart = raw.substring(start, end + 1);
        String textPart = raw.replaceRange(start, end + 1, "").trim();
        
        textPart = textPart.replaceAll('```json', '').replaceAll('```', '').trim();
        if (textPart.isEmpty) textPart = "Data diproses.";

        return (textPart, jsonDecode(jsonPart));
      }
    } catch (_) {
    }
    return (raw, null);
  }

  void _addMessage(String text, bool isUser, {bool isError = false}) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      isError: isError,
    ));
    notifyListeners();
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