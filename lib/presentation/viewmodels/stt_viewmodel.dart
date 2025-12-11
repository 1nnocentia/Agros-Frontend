import 'dart:async';
import 'dart:developer' as developer;
import 'package:agros/core/services/stt_service.dart';
import 'package:agros/data/models/stt_config_model.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttViewmodel extends ChangeNotifier {
  final SttService _service = SttService();
  
  Timer? _notifyTimer;

  bool _hasSpeech = false;
  bool _isListening = false;
  bool _isProcessing = false;

  double _level = 0.0;
  double _lastNotifiedLevel = 0.0;

  String _recognizedText = "";
  String _finalInput = "";
  String _lastStatus = "";
  String _lastError = "";

  List<LocaleName> _localeNammes = [];
  SttConfigModel _currentConfig = SttConfigModel.defaultConfig();

  bool get hasSpeech => _hasSpeech;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  double get level => _level;
  List<LocaleName> get localeNames => _localeNammes;

  String get recognizedText => _recognizedText;
  String get finalInput => _finalInput;
  String get lastStatus => _lastStatus;
  String get lastError => _lastError;

  SttConfigModel get currentConfig => _currentConfig;

  
  @override
  void dispose() {
    _notifyTimer?.cancel();
    super.dispose();
  }

  void _logSimple(String message) {
    if (kDebugMode && _currentConfig.logEvents) {
      debugPrint('[STT_VM] $message');
    }
  }

  void _notifyThrottled() {
    if (_notifyTimer != null && _notifyTimer!.isActive) return;
    
    _notifyTimer = Timer(const Duration(milliseconds: 200), () {
      notifyListeners();
      _notifyTimer = null;
    });
  }

  Future<void> initSpeechState() async {
    _logSimple('Init STT...');
    try {
      var hasSpeech = await _service.init(
        onError: _errorListener,
        onStatus: _statusListener,
        debugLogging: kDebugMode && _currentConfig.debugLogging, 
      );

      if(hasSpeech) {
        _localeNammes = await _service.getLocales();
        
        var systemLocale = await _service.getSystemLocale();
        String targetId = systemLocale?.localeId ?? "";

        for (var locale in _localeNammes) {
          if (locale.localeId == 'id_ID') {
            targetId = 'id_ID';
            break;
          }
        }
        
        _currentConfig = _currentConfig.copyWith(localeId: targetId);
        _logSimple('Locale selected: $targetId');
      } 

      _hasSpeech = hasSpeech;
      notifyListeners();
      
    } catch (e) {
      _logSimple('Error init: $e');
      _lastError = "Gagal init: $e";
      _hasSpeech = false;
      notifyListeners();
    }
  }
    
    void startListening() {
      _resetState();
      _lastError = "";
      _isListening = true;
      notifyListeners();

      try {
        _service.listen(
          config: _currentConfig,
          onResult: _resultListener,
          onSoundLevel: _soundLevelListener,
        );
      } catch (e) {
        _lastError = 'Error starting listening: $e';
        _isListening = false;
        notifyListeners();
      }
    }

    void stopListening() {
      try {
        _service.stop();
        _level = 0.0;
        _isListening = false;
        notifyListeners();
      } catch (e) {
        _logSimple('Error stop: $e');
      }
    }

    void cancelListening() {
      try {
        _service.cancel();
        _resetState();
        notifyListeners();
      } catch (e) {
        _logSimple('Error cancel: $e');
        notifyListeners();
      }
    }

    void _resetState() {
      _recognizedText = "";
      _finalInput = "";
      _level = 0.0;
      _lastError = "";
      _isProcessing = false;
    }

    void _resultListener(SpeechRecognitionResult result) {
      _recognizedText = result.recognizedWords;
      
      if (result.finalResult) {
        _logSimple('Final result received');

        _finalInput = result.recognizedWords;
        _isListening = false;
        _isProcessing = true;

        notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () {
        _isProcessing = false;
        notifyListeners();
      });
    } else {
      _notifyThrottled();
    }
  }

  void _statusListener(String status) {
    _logSimple('Status: $status');
    _lastStatus = status;

    bool shouldNotify = false;

    if (status == 'listening') {
      if (!_isListening) { _isListening = true; shouldNotify = true; }
    } 
    else if (status == 'notListening' || status == 'done') {
      if (_isListening) { _isListening = false; shouldNotify = true; }
    }
    
    if (shouldNotify) notifyListeners();
  }

  void _errorListener(SpeechRecognitionError error) {
    _logSimple('Error: ${error.errorMsg}');
    _lastError = error.errorMsg;
    
    if (error.errorMsg == 'error_no_match') {
       _recognizedText = "Tidak terdengar.";
    }
    
    _isListening = false;
    notifyListeners();
  }

  void _soundLevelListener(double level) {
    _level = level;

    if ((level - _lastNotifiedLevel).abs() > 2.0) {
       _lastNotifiedLevel = level;
       _notifyThrottled();
       
    }
  }
        // TODO: untuk fungsi firebase ai logic untuk proses input

        
}