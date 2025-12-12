import 'package:agros/core/services/stt_service.dart';
import 'package:agros/data/models/stt_config_model.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttViewmodel extends ChangeNotifier {
  final SttService _service = SttService();

  bool _hasSpeech = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _displayText = 'Tekan mikrofon untuk berbicara';

  double _level = 0.0;
  String _recognizedText = "";
  String _finalInput = "";
  String _lastStatus = "";
  String _lastError = "";
  String _lastwords = "";

  List<LocaleName> _localeNammes = [];
  SttConfigModel _currentConfig = SttConfigModel.defaultConfig();

  bool get hasSpeech => _hasSpeech;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  double get level => _level;
  List<LocaleName> get localeNames => _localeNammes;
  String get displayText => _displayText;

  String get recognizedText => _recognizedText;
  String get finalInput => _finalInput;
  String get lastStatus => _lastStatus;
  String get lastError => _lastError;
  String get lastWords => _lastwords;

  SttConfigModel get currentConfig => _currentConfig;

  Future<void> initSpeechState() async {
    _logEvent('Init STT');
    try {
      var hasSpeech = await _service.init(
        onError: _errorListener,
        onStatus: _statusListener,
        debugLogging: _currentConfig.debugLogging,
      );

      if(hasSpeech) {
        _localeNammes = await _service.getLocales();

        var indoLocale = _localeNammes.firstWhere(
          (locale) => locale.localeId.startsWith('id_'),
          orElse: () => LocaleName("", ""),
        );

        var targetLocaleId = indoLocale.localeId.isNotEmpty
          ? indoLocale.localeId
          : (await _service.getSystemLocale())?.localeId ?? "";

        _currentConfig = _currentConfig.copyWith(localeId: targetLocaleId);
      }

      _hasSpeech = hasSpeech;
      notifyListeners();
      } catch (e) {
        _lastError = "Gagal inisialisasi STT: $e";
        _hasSpeech = false;
        notifyListeners();
      }
    }
    
    void startListening() {
      _logEvent('Start Listening');
      _resetState();
      _lastError = "";
      _isListening = true;
      notifyListeners();

      _service.listen(
        config: _currentConfig,
        onResult: _resultListener,
        onSoundLevel: _soundLevelListener,
      );
    }

    void stopListening() {
      _logEvent('Stop Listening');
      _service.stop();
      _level = 0.0;
      _isListening = false;
      notifyListeners();
    }

    void cancelListening() {
      _logEvent('Cancel Listening');
      _level = 0.0;
      _isListening = false;
      _service.cancel();
      _resetState();
      notifyListeners();
    }

    void _resetState() {
      _recognizedText = "";
      _finalInput = "";
      _level = 0.0;
      _lastError = "";
      _isProcessing = false;
    }

    void _resultListener(SpeechRecognitionResult result) {
      _logEvent('Result listener: ${result.finalResult}, words: ${result.recognizedWords}');
      _recognizedText = result.recognizedWords;
      if (result.finalResult) {
        _finalInput = result.recognizedWords;
        _isListening = false;
        _isProcessing = true;

        debugPrint("✅ INPUT FINAL DITERIMA: $_finalInput");

        // TODO: untuk fungsi firebase ai logic untuk proses input

        Future.delayed(const Duration(seconds: 1), () {
          _isProcessing = false;
          notifyListeners();
        });
    }
      notifyListeners();
    }

    void toggleListening() {
      _isListening = !_isListening;
      _displayText = _isListening 
          ? 'Sedang mendengarkan...' 
          : 'Tekan mikrofon untuk berbicara';
      notifyListeners();
    }

    void _statusListener(String status) {
      _logEvent('Status listener: $status');
      _lastStatus = status;
      debugPrint("Status: $status");

      if (status == 'listening') {
        _isListening = true;
      } 
      else if (status == 'notListening' || status == 'done') {
        _isListening = false;
      }
      
      notifyListeners();
    }

    void _errorListener(SpeechRecognitionError error) {
      _logEvent('Received Error Status: $error');
      _lastError = '${error.errorMsg}';
      
      if (error.errorMsg == 'error_no_match') {
          _recognizedText = "Maaf, saya tidak mendengar apapun.";
      }
      
      _isListening = false;
      notifyListeners();
    }

    void _logEvent(String eventDescription) {
      if (_currentConfig.logEvents) {
        var eventTime = DateTime.now().toIso8601String();
        debugPrint("'$eventTime $eventDescription");
      }
    }

    void _soundLevelListener(double level) {
      _level = level;
      notifyListeners();
    }
}