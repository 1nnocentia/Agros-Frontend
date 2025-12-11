import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/wake_word_model.dart';

class PorcupineViewModel extends ChangeNotifier {
  String _status = "Inisialisasi...";
  bool _isListening = false;
  bool _isWakeWordDetected = false;
  
  String get status => _status;
  bool get isListening => _isListening;
  bool get isWakeWordDetected => _isWakeWordDetected;

  late WakeWordModel _model;


  Future<void> initService() async {
    _model = WakeWordModel(onWakeWordDetected: _onDetected);

    final accessKey = dotenv.env['PORCUPINE_ACCESS_KEY'] ?? "";
    const keywordPath = "assets/Halo-Agros_en_android.ppn";

    try {
      await _model.init(accessKey, keywordPath);
      
      await startListening();
      
    } catch (e) {
      _status = "Error: $e";
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    try {
      await _model.start();
      _isListening = true;
      _status = "Langsung Mendengarkan... Ucapkan 'Agros'";
      notifyListeners(); 
    } catch (e) {
      _status = "Gagal Start: $e";
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _model.stop();
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
    print("WAKE WORD TERDETEKSI DI VIEWMODEL!");
    
    _isWakeWordDetected = true;
    _status = "TERDETEKSI: Agros!";
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _isWakeWordDetected = false;
      _status = "Mendengarkan lagi...";
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}