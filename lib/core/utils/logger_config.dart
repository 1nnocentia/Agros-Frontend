import 'package:logging/logging.dart';

class LoggerConfig {
  static bool _isInitialized = false;

  static void initialize({Level level = Level.INFO}) {
    if (_isInitialized) return;

    Logger.root.level = level;

    Logger.root.onRecord.listen((record) {
      final time = record.time.toIso8601String();
      final levelName = record.level.name.padRight(7);
      final loggerName = record.loggerName.padRight(20);
      
      print('[$time] $levelName [$loggerName] ${record.message}');
      
      if (record.error != null) {
        print('  Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('  Stack trace:\n${record.stackTrace}');
      }
    });

    _isInitialized = true;
  }

  static void setLevel(Level level) {
    Logger.root.level = level;
  }

  static void disable() {
    Logger.root.level = Level.OFF;
  }

  static void enable({Level level = Level.INFO}) {
    Logger.root.level = level;
  }
}
