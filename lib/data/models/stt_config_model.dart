import 'package:speech_to_text/speech_to_text.dart';

class SttConfigModel {
  final SpeechListenOptions options;
  final String localeId;
  final bool logEvents;
  final bool debugLogging;
  final int pauseFor;
  final int listenFor;

  SttConfigModel(
    this.options,
    this.localeId,
    this.pauseFor,
    this.logEvents,
    this.debugLogging,
    this.listenFor,
  );
  
  factory SttConfigModel.defaultConfig() {

    return SttConfigModel(
      SpeechListenOptions(
        listenMode: ListenMode.dictation,
        onDevice: false,
        cancelOnError: false,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true,
      ),
      "",
      5,
      false,
      false,
      120,
    );
  }

  SttConfigModel copyWith({
    SpeechListenOptions? options,
    String? localeId,
    bool? logEvents,
    bool? debugLogging,
    int? pauseFor,
    int? listenFor,
  }) {
    return SttConfigModel(
      options ?? this.options,
      localeId ?? this.localeId,
      pauseFor ?? this.pauseFor,
      logEvents ?? this.logEvents,
      debugLogging ?? this.debugLogging,
      listenFor ?? this.listenFor,
    );
  }
}