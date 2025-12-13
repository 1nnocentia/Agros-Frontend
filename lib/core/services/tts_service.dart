import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  FlutterTts get instance => _flutterTts;

  Future<void> init() async {
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<dynamic> getLanguages() => _flutterTts.getLanguages;
  Future<dynamic> getEngines() => _flutterTts.getEngines;
  Future<dynamic> getDefaultEngine() => _flutterTts.getDefaultEngine;
  Future<dynamic> getDefaultVoice() => _flutterTts.getDefaultVoice;

  Future<void> setLanguage(String lang) => _flutterTts.setLanguage(lang);
  Future<void> setEngine(String engine) => _flutterTts.setEngine(engine);
  
  Future<void> setVolume(double volume) => _flutterTts.setVolume(volume);
  Future<void> setPitch(double pitch) => _flutterTts.setPitch(pitch);
  Future<void> setRate(double rate) => _flutterTts.setSpeechRate(rate);
  
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<dynamic> stop() => _flutterTts.stop();
  Future<dynamic> pause() => _flutterTts.pause();
}