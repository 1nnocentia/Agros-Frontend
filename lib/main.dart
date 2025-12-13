import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agros/core/theme/app_theme.dart';
// import 'package:agros/presentation/views/porcupine_page.dart';
// import 'package:agros/presentation/viewmodels/porcupine_viewmodel.dart';

import 'package:agros/presentation/viewmodels/stt_viewmodel.dart';

import 'package:agros/presentation/viewmodels/chat_viewmodel.dart';
import 'package:agros/presentation/views/chat_testing_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, 
  ));
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SttViewmodel()..initSpeechState(),
        ),

        ChangeNotifierProvider(
          create: (_) => ChatViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Agros',
        debugShowCheckedModeBanner: false,
        
        theme: AppTheme.lightTheme, 
        
        home: const ChatPage(),
      ),
    );
  }
}