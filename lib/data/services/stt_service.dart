

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
    return await _speechToText.initialize(
      onError: onError,
      onStatus: onStatus,
      debugLogging: debugLogging,
    );
  }

  Future<List<LocaleName>> getLocales() async {
    return await _speechToText.locales();
  }

  Future<LocaleName?> getSystemLocale() async {
    return await _speechToText.systemLocale();
  }

  Future<void> startListening({
    required SttConfigModel config,
    required Function(SpeechRecognitionResult) onResult,
    required Function(double) onSoundLevel,
  }) async {
    await _speechToText.listen(
      onResult: onResult,
      listenFor: Duration(seconds: config.listenFor),
      pauseFor: Duration(seconds: config.pauseFor),
      localeId: config.localeId,
      onSoundLevelChange: onSoundLevel,
      listenOptions: config.options,
    );
  }

  Future<void> stop() async {
    await _speechToText.stop();
  }

  Future<void> cancel() async {
    await _speechToText.cancel();
  }

}