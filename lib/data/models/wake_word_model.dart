import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class WakeWordModel {
  PorcupineManager? _porcupineManager;

  final Function(int) onWakeWordDetected;

  WakeWordModel({required this.onWakeWordDetected});

  Future<void> init(String accessKey, String keywordPath) async {
    try {
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        accessKey,
        [keywordPath],
        onWakeWordDetected,
      );
    } catch (e) {
      throw Exception("Gagal init Porcupine: $e");
    }
  }

  Future<void> start() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Izin mikrofon ditolak");
    }
    await _porcupineManager?.start();
  }

  Future<void> stop() async {
    await _porcupineManager?.stop();
  }

  Future<void> dispose() async {
    await _porcupineManager?.delete();
  }
}