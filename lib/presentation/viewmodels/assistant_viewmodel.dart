import 'dart:convert';
import 'package:agros/core/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:agros/data/repositories/agros_repository.dart';

import 'porcupine_viewmodel.dart';
import 'stt_viewmodel.dart';
import 'tts_viewmodel.dart';

enum AgrosState { standby, listeningCommand, processing, speaking }

class AssistantViewModel extends ChangeNotifier {
  static final Logger _logger = Logger('AssistantViewModel');

  final PorcupineViewModel wakeWordVm;
  final SttViewmodel sttVm;
  final TtsViewModel ttsVm;

  final AiService _aiService = AiService();
  final AgrosRepository _repo = AgrosRepository();

  AgrosState _state = AgrosState.standby;
  AgrosState get state => _state;

  String _displayText = "Hai Sahabat Agros!";
  String get displayText => _displayText;

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
      if (!sttVm.isListening &&
          sttVm.lastWords.isNotEmpty &&
          _state == AgrosState.listeningCommand) {
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
    _updateDisplay("Katakan 'Halo Agros'...");

    wakeWordVm.resetDetection();

    sttVm.stopListening();
    await ttsVm.stop();
    await wakeWordVm.startListening();
    _logger.info('AGROS: Mode Standby (Menunggu dipanggil)...');
  }

  Future<void> _startListeningUser() async {
    _setState(AgrosState.listeningCommand);
    _updateDisplay("Katakan 'Halo Agros'...");
    await wakeWordVm.stopListening();

    _logger.info('AGROS: Mendengarkan perintah user...');

    sttVm.startListening();
  }

  Future<void> _processToAI(String text) async {
    _setState(AgrosState.processing);
    _updateDisplay("Sedang memproses...");
    _logger.info('AGROS: Mengirim ke AI -> $text');

    try {
      final rawResponse = await _aiService.sendMessage(text);
      final (speechText, jsonData) = _parseAiResponse(rawResponse);

      String responseToSpeak = speechText;

      if (jsonData != null) {
        String action = jsonData['action'] ?? jsonData['intent'] ?? '';
        Map<String, dynamic> data = jsonData['data'] ?? {};

        _logger.info("ACTION: $action | DATA: $data");

        if (action.isNotEmpty) {
          if (action.startsWith('get_')) {
            responseToSpeak = await _handleGetData(action, data);
          } else {
            bool success = await _executeTransaction(action, data);
            if (!success)
              responseToSpeak = "Gagal menyimpan data. Cek koneksi internet.";
          }
        }
      }

      _updateDisplay(responseToSpeak);
      await _speakResponse(responseToSpeak);
    } catch (e) {
      _logger.severe("Error Processing: $e");

      String errorMessage = "Maaf, ada gangguan sistem.";

      if (e.toString().contains("Quota exceeded") ||
          e.toString().contains("429")) {
        errorMessage =
            "Maaf, server AI sedang sibuk (Limit Habis). Mohon tunggu 1 menit lagi.";
      } else if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        errorMessage = "Gagal terhubung ke internet/server.";
      }

      _updateDisplay(errorMessage);
      await _speakResponse(errorMessage);
    }
  }

  Future<String> _handleGetData(
    String action,
    Map<String, dynamic> data,
  ) async {
    _updateDisplay("Mengambil data...");

    switch (action) {
      case 'get_lahan':
        final list = await _repo.lahan.getLahanList();
        if (list.isEmpty) return "Anda belum memiliki data lahan.";

        StringBuffer sb = StringBuffer();
        sb.write("Anda memiliki ${list.length} lahan. ");
        for (var item in list) {
          sb.write(
            "Lahan ${item['lahan_name']} seluas ${item['land_area']} hektar. ",
          );
        }
        return sb.toString();

      case 'get_tanam':
        final list = await _repo.tanam.getTanamOngoing();
        if (list.isEmpty) return "Tidak ada tanaman yang sedang aktif.";

        StringBuffer sb = StringBuffer();
        sb.write("Ada ${list.length} tanaman aktif. ");
        for (var item in list) {
          sb.write(
            "Tanaman ${item['komoditas_name'] ?? 'Padi'} di lahan ${item['lahan_name']}. ",
          );
        }
        return sb.toString();

      case 'get_komoditas':
        final list = await _repo.master.getKomoditas();
        if (list.isEmpty) return "Belum ada daftar komoditas yang tersedia.";

        StringBuffer sb = StringBuffer();
        sb.write("Komoditas yang tersedia: ");
        for (var i = 0; i < list.length; i++) {
          sb.write(list[i]['name'] ?? list[i]['komoditas_name'] ?? 'Item $i');
          if (i < list.length - 1) sb.write(", ");
        }
        sb.write(".");
        return sb.toString();

      case 'get_varietas':
        final list = await _repo.master.getVarietas();
        if (list.isEmpty) return "Belum ada daftar varietas yang tersedia.";

        StringBuffer sb = StringBuffer();
        sb.write("Varietas yang tersedia: ");
        for (var i = 0; i < list.length; i++) {
          sb.write(list[i]['name'] ?? list[i]['varietas_name'] ?? 'Item $i');
          if (i < list.length - 1) sb.write(", ");
        }
        sb.write(".");
        return sb.toString();

      case 'get_kelompok_tani':
        final list = await _repo.master.getKelompokTani();
        if (list.isEmpty)
          return "Belum ada daftar kelompok tani yang terdaftar.";

        StringBuffer sb = StringBuffer();
        sb.write("Kelompok tani yang terdaftar: ");
        for (var i = 0; i < list.length; i++) {
          sb.write(list[i]['name'] ?? list[i]['kelompok_name'] ?? 'Item $i');
          if (i < list.length - 1) sb.write(", ");
        }
        sb.write(".");
        return sb.toString();

      default:
        return "Data tidak ditemukan.";
    }
  }

  Future<bool> _executeTransaction(
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      String? getId() {
        if (data['id'] != null) return data['id'].toString();
        for (var k in data.keys) {
          if (k.endsWith('_id') && k != 'role_id') return data[k].toString();
        }
        return null;
      }

      _logger.info('Executing transaction: $action with data: $data');

      switch (action) {
        case 'simpan_lahan':
          _logger.info('Creating lahan...');
          return await _repo.lahan.createLahan(data);

        case 'simpan_tanam':
          _logger.info('Creating tanam...');
          return await _repo.tanam.createTanam(data);

        case 'simpan_panen':
          _logger.info('Creating panen...');
          return await _repo.panen.createPanen(data);

        case 'update_lahan':
          String? id = getId();
          if (id == null) {
            _logger.warning('Update lahan: ID not found in data');
            return false;
          }
          _logger.info('Updating lahan with id: $id');
          data.remove('id');
          data.remove('lahan_id');
          return await _repo.lahan.updateLahan(id, data);

        case 'update_tanam':
          String? id = getId();
          if (id == null) {
            _logger.warning('Update tanam: ID not found in data');
            return false;
          }
          _logger.info('Updating tanam with id: $id');
          data.remove('id');
          data.remove('tanam_id');
          return await _repo.tanam.updateTanam(id, data);

        case 'update_panen':
          String? id = getId();
          if (id == null) {
            _logger.warning('Update panen: ID not found in data');
            return false;
          }
          _logger.info('Updating panen with id: $id');
          data.remove('id');
          data.remove('panen_id');
          return await _repo.panen.updatePanen(id, data);

        case 'verify_panen':
          String? id = getId();
          if (id == null) {
            _logger.warning('Verify panen: ID not found in data');
            return false;
          }
          _logger.info('Verifying panen with id: $id');
          return await _repo.panen.verifyPanen(id);

        default:
          _logger.warning('Unknown action: $action');
          return true;
      }
    } catch (e) {
      _logger.severe('Error in _executeTransaction: $e');
      return false;
    }
  }

  Future<void> _speakResponse(String text) async {
    _setState(AgrosState.speaking);
    _lastResponse = text;
    await ttsVm.speak(text);
  }

  void _updateDisplay(String text) {
    _displayText = text;
    notifyListeners();
  }

  void _setState(AgrosState s) {
    _state = s;
    notifyListeners();
  }

  (String, Map<String, dynamic>?) _parseAiResponse(String raw) {
    try {
      int start = raw.indexOf('{');
      int end = raw.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        String jsonPart = raw.substring(start, end + 1);
        String textPart = raw.replaceRange(start, end + 1, "").trim();
        textPart = textPart
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        if (textPart.isEmpty) textPart = "Permintaan diproses.";
        return (textPart, jsonDecode(jsonPart));
      }
    } catch (_) {}
    return (raw, null);
  }

  void manualStartListening() {
    _startListeningUser();
  }

  void manualStopListening() {
    sttVm.stopListening();
  }
}
