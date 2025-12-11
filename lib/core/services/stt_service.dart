
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:agros/data/models/stt_config_model.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();

  bool get isListening => _speechToText.isListening;
  bool get hasSpeech => _speechToText.isAvailable;

  Future<bool> init({
    required Function(SpeechRecognitionError) onError,
    required Function(String) onStatus,
    bool debugLogging = false,
  }) async {
    _log('🔧 [STT_SERVICE] Initializing speech recognition...');
    _log('🔧 [STT_SERVICE] Debug logging: $debugLogging');
    
    try {
      final result = await _speechToText.initialize(
        onError: onError,
        onStatus: onStatus,
        debugLogging: debugLogging,
      );
      
      if (result) {
        _log('✅ [STT_SERVICE] Speech recognition initialized successfully');
        _log('📊 [STT_SERVICE] isAvailable: ${_speechToText.isAvailable}');
      } else {
        _log('❌ [STT_SERVICE] Speech recognition initialization failed');
      }
      
      return result;
    } catch (e, stackTrace) {
      _log('💥 [STT_SERVICE] Exception during initialization: $e');
      _log('📜 [STT_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<LocaleName>> getLocales() async {
    _log('🌍 [STT_SERVICE] Fetching available locales...');
    try {
      final locales = await _speechToText.locales();
      _log('✅ [STT_SERVICE] Found ${locales.length} locales');
      for (var locale in locales) {
        _log('   - ${locale.localeId}: ${locale.name}');
      }
      return locales;
    } catch (e, stackTrace) {
      _log('💥 [STT_SERVICE] Error getting locales: $e');
      _log('📜 [STT_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<LocaleName?> getSystemLocale() async {
    _log('🌍 [STT_SERVICE] Fetching system locale...');
    try {
      final locale = await _speechToText.systemLocale();
      _log('✅ [STT_SERVICE] System locale: ${locale?.localeId} (${locale?.name})');
      return locale;
    } catch (e, stackTrace) {
      _log('💥 [STT_SERVICE] Error getting system locale: $e');
      _log('📜 [STT_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> listen({
    required SttConfigModel config,
    required Function(SpeechRecognitionResult) onResult,
    required Function(double) onSoundLevel,
  }) async {
    _log('🎤 [STT_SERVICE] Starting to listen...');
    _log('📋 [STT_SERVICE] Config:');
    _log('   - Locale: ${config.localeId}');
    _log('   - Listen for: ${config.listenFor}s');
    _log('   - Pause for: ${config.pauseFor}s');
    _log('   - Partial results: ${config.options.partialResults}');
    _log('   - On device: ${config.options.onDevice}');
    _log('   - Auto punctuation: ${config.options.autoPunctuation}');
    _log('   - Cancel on error: ${config.options.cancelOnError}');
    
    try {
      await _speechToText.listen(
        onResult: (result) {
          // Log hanya final results untuk mengurangi spam
          if (result.finalResult) {
            _log('📝 [STT_SERVICE] Final result: "${result.recognizedWords}"');
          }
          onResult(result);
        },
        listenFor: Duration(seconds: config.listenFor),
        pauseFor: Duration(seconds: config.pauseFor),
        localeId: config.localeId,
        onSoundLevelChange: (level) {
          // Tidak log sound level karena terlalu sering (ratusan kali/detik)
          // Hanya log jika level sangat tinggi
          if (level > 5.0) {
            _log('🔊 [STT_SERVICE] Very high sound: ${level.toStringAsFixed(1)}');
          }
          onSoundLevel(level);
        },
        listenOptions: config.options,
      );
      _log('✅ [STT_SERVICE] Listen started successfully');
    } catch (e, stackTrace) {
      _log('💥 [STT_SERVICE] Error starting listen: $e');
      _log('📜 [STT_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> stop() async {
    _log('⏹️ [STT_SERVICE] Stopping speech recognition...');
    try {
      await _speechToText.stop();
      _log('✅ [STT_SERVICE] Speech recognition stopped');
    } catch (e, stackTrace) {
      _log('💥 [STT_SERVICE] Error stopping: $e');
      _log('📜 [STT_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancel() async {
    _log('❌ [STT_SERVICE] Cancelling speech recognition...');
    try {
      await _speechToText.cancel();
      _log('✅ [STT_SERVICE] Speech recognition cancelled');
    } catch (e, stackTrace) {
      _log('💥 [STT_SERVICE] Error cancelling: $e');
      _log('📜 [STT_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    
    // Log ke console dengan debugPrint
    debugPrint(logMessage);
    
    // Log ke developer console untuk lebih detail
    developer.log(
      message,
      time: DateTime.now(),
      name: 'STT_SERVICE',
    );
  }
}