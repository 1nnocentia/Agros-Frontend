import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:agros/presentation/views/porcupine_page.dart';
import 'package:agros/presentation/viewmodels/porcupine_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PorcupineViewModel()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PorcupinePage(),
      ),
    ),
  );
}