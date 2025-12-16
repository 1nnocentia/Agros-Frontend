import 'package:agros/data/models/stt_config_model.dart';
import 'package:logging/logging.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  static final Logger _logger = Logger('SttService');
  final SpeechToText _speechToText = SpeechToText();

  bool get isListening => _speechToText.isListening;
  bool get hasSpeech => _speechToText.isAvailable;

  Future<bool> init({
    required Function(SpeechRecognitionError) onError,
    required Function(String) onStatus,
    bool debugLogging = false,
  }) async {
    _logger.info('Initializing speech recognition...');
    _logger.info('Debug logging: $debugLogging');
    
    try {
      final result = await _speechToText.initialize(
        onError: onError,
        onStatus: onStatus,
        debugLogging: debugLogging,
      );
      
      if (result) {
        _logger.info('Speech recognition initialized successfully');
        _logger.info('isAvailable: ${_speechToText.isAvailable}');
      } else {
        _logger.warning('Speech recognition initialization failed');
      }
      
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Exception during initialization', e, stackTrace);
      rethrow;
    }
  }

  Future<List<LocaleName>> getLocales() async {
    _logger.fine('Fetching available locales...');
    try {
      final locales = await _speechToText.locales();
      _logger.info('Found ${locales.length} locales');
      for (var locale in locales) {
        _logger.fine('  - ${locale.localeId}: ${locale.name}');
      }
      return locales;
    } catch (e, stackTrace) {
      _logger.severe('Error getting locales', e, stackTrace);
      rethrow;
    }
  }

  Future<LocaleName?> getSystemLocale() async {
    _logger.fine('Fetching system locale...');
    try {
      final locale = await _speechToText.systemLocale();
      _logger.info('System locale: ${locale?.localeId} (${locale?.name})');
      return locale;
    } catch (e, stackTrace) {
      _logger.severe('Error getting system locale', e, stackTrace);
      rethrow;
    }
  }

  Future<void> listen({
    required SttConfigModel config,
    required Function(SpeechRecognitionResult) onResult,
    required Function(double) onSoundLevel,
  }) async {
    _logger.info('Starting to listen...');
    _logger.config('Config:');
    _logger.config('  - Locale: ${config.localeId}');
    _logger.config('  - Listen for: ${config.listenFor}s');
    _logger.config('  - Pause for: ${config.pauseFor}s');
    _logger.config('  - Partial results: ${config.options.partialResults}');
    _logger.config('  - On device: ${config.options.onDevice}');
    _logger.config('  - Auto punctuation: ${config.options.autoPunctuation}');
    _logger.config('  - Cancel on error: ${config.options.cancelOnError}');
    
    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _logger.info('Final result: "${result.recognizedWords}"');
          }
          onResult(result);
        },
        listenFor: Duration(seconds: config.listenFor),
        pauseFor: Duration(seconds: config.pauseFor),
        localeId: config.localeId,
        onSoundLevelChange: (level) {
          onSoundLevel(level);
          if (level > 5.0) {
          }
        },
        listenOptions: config.options,
      );
      _logger.fine('Listen started successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error starting listen', e, stackTrace);
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _speechToText.stop();
      _logger.info('Speech recognition stopped');
    } catch (e, stackTrace) {
      _logger.severe('Error stopping', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancel() async {
    try {
      await _speechToText.cancel();
      _logger.info('Speech recognition cancelled');
    } catch (e, stackTrace) {
      _logger.severe('Error cancelling', e, stackTrace);
      rethrow;
    }
  }
}