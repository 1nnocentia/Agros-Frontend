import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';

import 'presentation/viewmodels/stt_viewmodel.dart';
import 'presentation/viewmodels/tts_viewmodel.dart';

import 'package:agros/presentation/views/basic_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const AgrosApp());
}

class AgrosApp extends StatelessWidget {
  const AgrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SttViewmodel()..initSpeechState(),
        ),

        ChangeNotifierProvider(
          create: (_) => TtsViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Agros',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme, 

        home: const BasicView(),
      ),
    );
  }
}