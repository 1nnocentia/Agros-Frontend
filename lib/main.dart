import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/logger_config.dart';
import 'core/services/ai_service.dart';

import 'presentation/viewmodels/stt_viewmodel.dart';
import 'presentation/viewmodels/tts_viewmodel.dart';
import 'package:agros/presentation/viewmodels/porcupine_viewmodel.dart';
import 'package:agros/presentation/viewmodels/assistant_viewmodel.dart';

import 'package:agros/presentation/widgets/auth_guard.dart';

import 'package:agros/data/repositories/agros_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LoggerConfig.initialize(level: Level.INFO);

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AgrosApp());
}

class AgrosApp extends StatelessWidget {
  const AgrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final agrosRepository = AgrosRepository();
    final aiService = AiService();
    
    return MultiProvider(
      providers: [
        Provider<AgrosRepository>.value(value: agrosRepository),
        Provider<AiService>.value(value: aiService),

        ChangeNotifierProvider(
          create: (_) => SttViewmodel()..initSpeechState(),
        ),

        ChangeNotifierProvider(create: (_) => TtsViewModel()),

        ChangeNotifierProvider(
          create: (_) => PorcupineViewModel()..initService(),
        ),

        ChangeNotifierProxyProvider3<
          PorcupineViewModel,
          SttViewmodel,
          TtsViewModel,
          AssistantViewModel
        >(
          create: (context) => AssistantViewModel(
            wakeWordVm: Provider.of<PorcupineViewModel>(context, listen: false),
            sttVm: Provider.of<SttViewmodel>(context, listen: false),
            ttsVm: Provider.of<TtsViewModel>(context, listen: false),
            aiService: aiService,
            repository: agrosRepository,
          ),
          update: (context, porcupine, stt, tts, previous) => previous!,
        ),
      ],
      child: MaterialApp(
        title: 'Agros',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGuard(),
      ),
    );
  }
}
