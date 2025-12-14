import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:agros/core/services/tts_service.dart';



enum TtsState {playing, stopped, paused, continued}

class TtsViewModel extends ChangeNotifier {
  final TtsService _service = TtsService();

  TtsState _ttsState = TtsState.stopped;

  String? _language;
  String? _engine;

  double _volume = 0.8;
  double _pitch = 1.0;
  double _rate = 0.5;

  bool _isCurrentLanguageInstalled = false;
  int? _inputLength;

  List<String> _languages = [];
  List<String> _engines = [];

  TtsState get ttsState => _ttsState;
  String? get language => _language;
  String? get engine => _engine;
  double get volume => _volume;
  double get pitch => _pitch;
  double get rate => _rate;
  bool get isCurrentLanguageInstalled => _isCurrentLanguageInstalled;
  int? get inputLength => _inputLength;
  List<String> get languages => _languages;
  List<String> get engines => _engines;

  bool get isPlaying => _ttsState == TtsState.playing;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  TtsViewModel() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _service.init();
    
    await _loadLanguages();
    if (isAndroid) {
      await _loadEngines();
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    final systemLanguageCode = "${systemLocale.languageCode}-${systemLocale.countryCode}";

    debugPrint("System Locale User: $systemLanguageCode");

    bool hasIndonesian = _languages.contains('id-ID');
    
    bool hasSystemLang = _languages.contains(systemLanguageCode);

    if (systemLanguageCode == 'id-ID' && hasIndonesian) {
      await setLanguage('id-ID');
      debugPrint("Menggunakan Bahasa Indonesia (Sesuai System).");
    } else if (hasSystemLang) {
      await setLanguage(systemLanguageCode);
      debugPrint("Menggunakan Bahasa System: $systemLanguageCode");
    } else if (hasIndonesian) {
      await setLanguage('id-ID');
      debugPrint("Bahasa System tidak didukung. Fallback ke Bahasa Indonesia.");
    } else {
      debugPrint("Tidak ada bahasa yang cocok. Menggunakan default engine.");
    }

    _service.instance.setStartHandler(() {
      _ttsState = TtsState.playing;
      notifyListeners();
    });

    _service.instance.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _service.instance.setCancelHandler(() {
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _service.instance.setPauseHandler(() {
      _ttsState = TtsState.paused;
      notifyListeners();
    });

    _service.instance.setContinueHandler(() {
      _ttsState = TtsState.continued;
      notifyListeners();
    });

    _service.instance.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      _ttsState = TtsState.stopped;
      notifyListeners();
    });
  }

  Future<void> _loadLanguages() async {
    try {
      dynamic langs = await _service.getLanguages();
      if (langs != null && langs is List) {
        _languages = langs.map((e) => e.toString()).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading languages: $e");
    }
  }

  Future<void> _loadEngines() async {
    try {
      dynamic engines = await _service.getEngines();
      if (engines != null && engines is List) {
        _engines = engines.map((e) => e.toString()).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading engines: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    
    await _service.setVolume(_volume);
    await _service.setRate(_rate);
    await _service.setPitch(_pitch);
    
    if (_language != null) {
      await _service.setLanguage(_language!);
    }

    await _service.speak(text);
  }

  Future<void> stop() async {
    var result = await _service.stop();
    if (result == 1) {
      _ttsState = TtsState.stopped;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    var result = await _service.pause();
    if (result == 1) {
      _ttsState = TtsState.paused;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String? lang) async {
    _language = lang;
    if (lang != null) {
      await _service.setLanguage(lang);
      if (isAndroid) {
        var installed = await _service.instance.isLanguageInstalled(lang);
        _isCurrentLanguageInstalled = (installed as bool);
        
        if (!_isCurrentLanguageInstalled) {
          debugPrint("Peringatan: Bahasa $lang belum di-download di pengaturan HP Android.");
        }
      }
    }
    notifyListeners();
  }

  void setEngine(String? newEngine) async {
    _engine = newEngine;
    if (newEngine != null) {
      await _service.setEngine(newEngine);
    }
    notifyListeners();
  }

  void updateVolume(double val) {
    _volume = val;
    notifyListeners();
  }

  void updatePitch(double val) {
    _pitch = val;
    notifyListeners();
  }

  void updateRate(double val) {
    _rate = val;
    notifyListeners();
  }
  
  Future<void> getMaxInputLength() async {
    _inputLength = await _service.instance.getMaxSpeechInputLength;
    notifyListeners();
  }
}