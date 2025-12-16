import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import '../../core/services/wake_word_service.dart';

class PorcupineViewModel extends ChangeNotifier {
  static final Logger _logger = Logger('PorcupineViewModel');
  String _status = "Inisialisasi...";
  bool _isListening = false;
  bool _isWakeWordDetected = false;
  
  String get status => _status;
  bool get isListening => _isListening;
  bool get isWakeWordDetected => _isWakeWordDetected;

  late WakeWordService _service;


  Future<void> initService() async {
    _service = WakeWordService(onWakeWordDetected: _onDetected);

    final accessKey = dotenv.env['PORCUPINE_ACCESS_KEY'] ?? "";
    const keywordPath = "assets/Halo-Agros_en_android.ppn";

    try {
      await _service.init(accessKey, keywordPath);
      
      await startListening();
      
    } catch (e) {
      _status = "Error: $e";
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    try {
      await _service.start();
      _isListening = true;
      _status = "Langsung Mendengarkan... Ucapkan 'Agros'";
      notifyListeners(); 
    } catch (e) {
      _status = "Gagal Start: $e";
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _service.stop();
    _isListening = false;
    _status = "Berhenti (Idle)";
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  void _onDetected(int index) {
    _logger.info('WAKE WORD TERDETEKSI DI VIEWMODEL!');
    
    _isWakeWordDetected = true;
    _status = "Hi Sahabat Agros!";
    notifyListeners();

    // Future.delayed(const Duration(milliseconds: 1500), () {
    //   _isWakeWordDetected = false;
    //   _status = "Mendengarkan lagi...";
    //   notifyListeners();
    // });
  }

  void resetDetection() {
    _isWakeWordDetected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
    
  }
}