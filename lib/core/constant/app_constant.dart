import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstant {
  static String get porcupineAccessKey => dotenv.env['PORCUPINE_ACCESS_KEY'] ?? '';
}