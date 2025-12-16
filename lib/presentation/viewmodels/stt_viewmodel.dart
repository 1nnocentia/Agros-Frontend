import 'package:agros/core/services/stt_service.dart';
import 'package:agros/data/models/stt_config_model.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SttViewmodel extends ChangeNotifier {
  static final Logger _logger = Logger('SttViewmodel');
  final SttService _service = SttService();

  VoidCallback? onStartListeningAnimation;
  VoidCallback? onStopListeningAnimation;

  bool _hasSpeech = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _displayText = 'Tekan mikrofon untuk berbicara';

  final ValueNotifier<double> soundLevelNotifier = ValueNotifier(0.0);
  String _recognizedText = "";
  String _finalInput = "";
  String _lastStatus = "";
  String _lastError = "";
  String _lastwords = "";

  SttConfigModel _currentConfig = SttConfigModel.defaultConfig();

  bool get hasSpeech => _hasSpeech;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
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

        var systemLocale = await _service.getSystemLocale();
        String targetId = 'id_ID';
        if (systemLocale?.localeId == 'in_ID') {
         targetId = 'in_ID';
      }

        _currentConfig = _currentConfig.copyWith(localeId: targetId);
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
      _displayText = '';

      onStartListeningAnimation?.call();
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
      _isListening = false;

      onStopListeningAnimation?.call();
      
      if (_finalInput.isNotEmpty) {
        _displayText = _finalInput;
      } else {
        _displayText = 'Tekan mikrofon untuk berbicara';
      }
      
      notifyListeners();
    }

    void cancelListening() {
      _logEvent('Cancel Listening');
      _isListening = false;
      _service.cancel();
      _resetState();
      notifyListeners();
    }

    void _resetState() {
      _recognizedText = "";
      _finalInput = "";
      _lastError = "";
      _isProcessing = false;
    }

    void _resultListener(SpeechRecognitionResult result) {
      _logEvent('Result listener: ${result.finalResult}, words: ${result.recognizedWords}');
      _recognizedText = result.recognizedWords;
      _lastwords = result.recognizedWords;
      
      if (result.recognizedWords.isNotEmpty) {
        _displayText = result.recognizedWords;
      } else if (_isListening && _displayText.isEmpty) {
        _displayText = 'Mendengarkan...';
      }
      
      if (result.finalResult) {
        _finalInput = result.recognizedWords;
        _isListening = false;
        _isProcessing = true;

        _logEvent("✅ INPUT FINAL DITERIMA: $_finalInput");

        // TODO: untuk fungsi firebase ai logic untuk proses input

        Future.delayed(const Duration(seconds: 1), () {
          _isProcessing = false;
          notifyListeners();
        });
      }
      
      notifyListeners();
    }

    void toggleListening() {
      if (!_hasSpeech) {
        _displayText = 'Speech recognition tidak tersedia';
        notifyListeners();
        return;
      }

      if (_isListening) {
        stopListening();
      } else {
        startListening();
      }
    }

    void _statusListener(String status) {
      _logEvent('Status listener: $status');
      _lastStatus = status;
      _logger.fine('Status: $status');

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
        _displayText = "Tidak ada suara terdeteksi";
      } else if (error.errorMsg == 'error_network') {
        _displayText = "Koneksi bermasalah";
      } else {
        _displayText = "Error: ${error.errorMsg}";
      }
      
      _isListening = false;
      notifyListeners();
    }

    void _logEvent(String eventDescription) {
      if (_currentConfig.logEvents) {
        var eventTime = DateTime.now().toIso8601String();
        _logger.config('$eventTime $eventDescription');
      }
    }

    void _soundLevelListener(double level) {
      soundLevelNotifier.value = level;
    }

    @override
    void dispose() {
      soundLevelNotifier.dispose();
      super.dispose();
    }
}