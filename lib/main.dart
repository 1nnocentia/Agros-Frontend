import 'package:agros/presentation/views/basic_view.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:agros/core/theme/app_theme.dart';
// import 'package:agros/presentation/views/porcupine_page.dart';
// import 'package:agros/presentation/viewmodels/porcupine_viewmodel.dart';

import 'package:agros/presentation/viewmodels/stt_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SttViewmodel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const BasicView(),
      ),
    ),
  );
}